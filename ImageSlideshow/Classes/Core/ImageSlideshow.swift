//
//  ImageSlideshow.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import UIKit

/** 
    Used to represent position of the Page Control
    - hidden: Page Control is hidden
    - insideScrollView: Page Control is inside image slideshow
    - underScrollView: Page Control is under image slideshow
    - custom: Custom vertical padding, relative to "insideScrollView" position
 */
public enum PageControlPosition {
    case hidden
    case insideScrollView
    case underScrollView
    case custom(padding: CGFloat)

    var bottomPadding: CGFloat {
        switch self {
        case .hidden, .insideScrollView:
            return 0.0
        case .underScrollView:
            return 30.0
        case .custom(let padding):
            return padding
        }
    }
}

/// Used to represent image preload strategy
///
/// - fixed: preload only fixed number of images before and after the current image
/// - all: preload all images in the slideshow
public enum ImagePreload {
    case fixed(offset: Int)
    case all
}

/// Main view containing the Image Slideshow
@objcMembers
open class ImageSlideshow: UIView {

    /// Scroll View to wrap the slideshow
    open let scrollView = UIScrollView()

    /// Page Control shown in the slideshow
    open let pageControl = UIPageControl()

    /// Activity indicator shown when loading image
    open var activityIndicator: ActivityIndicatorFactory? {
        didSet {
            self.reloadScrollView()
        }
    }

    // MARK: - State properties

    /// Page control position
    open var pageControlPosition = PageControlPosition.insideScrollView {
        didSet {
            setNeedsLayout()
        }
    }

    /// Current page
    open fileprivate(set) var currentPage: Int = 0 {
        didSet {
            if oldValue != currentPage {
                currentPageChanged?(currentPage)
            }
        }
    }

    /// Called on each currentPage change
    open var currentPageChanged: ((_ page: Int) -> ())?

    /// Called on scrollViewWillBeginDragging
    open var willBeginDragging: (() -> ())?

    /// Called on scrollViewDidEndDecelerating
    open var didEndDecelerating: (() -> ())?

    /// Currenlty displayed slideshow item
    open var currentSlideshowItem: ImageSlideshowItem? {
        if slideshowItems.count > scrollViewPage {
            return slideshowItems[scrollViewPage]
        } else {
            return nil
        }
    }

    /// Current scroll view page. This may differ from `currentPage` as circular slider has two more dummy pages at indexes 0 and n-1 to provide fluent scrolling between first and last item.
    open fileprivate(set) var scrollViewPage: Int = 0

    /// Input Sources loaded to slideshow
    open fileprivate(set) var images = [InputSource]()

    /// Image Slideshow Items loaded to slideshow
    open fileprivate(set) var slideshowItems = [ImageSlideshowItem]()

    // MARK: - Preferences

    /// Enables/disables infinite scrolling between images
    open var circular = true {
        didSet {
            if self.images.count > 0 {
                self.setImageInputs(self.images)
            }
        }
    }

    /// Enables/disables user interactions
    open var draggingEnabled = true {
        didSet {
            self.scrollView.isUserInteractionEnabled = draggingEnabled
        }
    }

    /// Enables/disables zoom
    open var zoomEnabled = false {
        didSet {
            self.reloadScrollView()
        }
    }
    
    /// Maximum zoom scale
    open var maximumScale: CGFloat = 2.0 {
        didSet {
            self.reloadScrollView()
        }
    }

    /// Image change interval, zero stops the auto-scrolling
    open var slideshowInterval = 0.0 {
        didSet {
            self.slideshowTimer?.invalidate()
            self.slideshowTimer = nil
            setTimerIfNeeded()
        }
    }

    /// Image preload configuration, can be sed to .fixed to enable lazy load or .all
    open var preload = ImagePreload.all

    /// Content mode of each image in the slideshow
    open var contentScaleMode: UIViewContentMode = UIViewContentMode.scaleAspectFit {
        didSet {
            for view in slideshowItems {
                view.imageView.contentMode = contentScaleMode
            }
        }
    }

    fileprivate var slideshowTimer: Timer?
    fileprivate var scrollViewImages = [InputSource]()

    /// Transitioning delegate to manage the transition to full screen controller
    open fileprivate(set) var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate?
    
    var primaryVisiblePage: Int {
        return scrollView.frame.size.width > 0 ? Int(scrollView.contentOffset.x + scrollView.frame.size.width / 2) / Int(scrollView.frame.size.width) : 0
    }

    // MARK: - Life cycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    fileprivate func initialize() {
        autoresizesSubviews = true
        clipsToBounds = true

        // scroll view configuration
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - 50.0)
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = self.autoresizingMask
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)

        addSubview(pageControl)
        pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)

        setTimerIfNeeded()
        layoutScrollView()
    }

    open override func removeFromSuperview() {
        super.removeFromSuperview()
        self.pauseTimer()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        // fixes the case when automaticallyAdjustsScrollViewInsets on parenting view controller is set to true
        scrollView.contentInset = UIEdgeInsets.zero

        layoutPageControl()
        layoutScrollView()
    }

    open func layoutPageControl() {
        if case .hidden = self.pageControlPosition {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = self.images.count < 2
        }

        var pageControlBottomInset: CGFloat = 12.0
        if #available(iOS 11.0, *) {
            pageControlBottomInset += self.safeAreaInsets.bottom
        }

        pageControl.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 10)
        pageControl.center = CGPoint(x: frame.size.width / 2, y: frame.size.height - pageControlBottomInset)
    }

    /// updates frame of the scroll view and its inner items
    func layoutScrollView() {
        let scrollViewBottomPadding: CGFloat = pageControlPosition.bottomPadding
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - scrollViewBottomPadding)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewImages.count), height: scrollView.frame.size.height)

        for (index, view) in self.slideshowItems.enumerated() {
            if !view.zoomInInitially {
                view.zoomOut()
            }
            view.frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        }

        setCurrentPage(currentPage, animated: false)
    }

    /// reloads scroll view with latest slideshow items
    func reloadScrollView() {
        // remove previous slideshow items
        for view in self.slideshowItems {
            view.removeFromSuperview()
        }
        self.slideshowItems = []

        var i = 0
        for image in scrollViewImages {
            let item = ImageSlideshowItem(image: image, zoomEnabled: self.zoomEnabled, activityIndicator: self.activityIndicator?.create(), maximumScale: maximumScale)
            item.imageView.contentMode = self.contentScaleMode
            slideshowItems.append(item)
            scrollView.addSubview(item)
            i += 1
        }

        if circular && (scrollViewImages.count > 1) {
            scrollViewPage = 1
            scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: false)
        } else {
            scrollViewPage = 0
        }

        loadImages(for: scrollViewPage)
    }

    private func loadImages(for scrollViewPage: Int) {
        let totalCount = slideshowItems.count

        for i in 0..<totalCount {
            let item = slideshowItems[i]
            switch self.preload {
            case .all:
                item.loadImage()
            case .fixed(let offset):
                // if circular scrolling is enabled and image is on the edge, a helper ("dummy") image on the other side needs to be loaded too
                let circularEdgeLoad = circular && ((scrollViewPage == 0 && i == totalCount-3) || (scrollViewPage == 0 && i == totalCount-2) || (scrollViewPage == totalCount-2 && i == 1))

                // load image if page is in range of loadOffset, else release image
                let shouldLoad = abs(scrollViewPage-i) <= offset || abs(scrollViewPage-i) > totalCount-offset || circularEdgeLoad
                shouldLoad ? item.loadImage() : item.releaseImage()
            }
        }
    }

    // MARK: - Image setting

    /**
     Set image inputs into the image slideshow
     - parameter inputs: Array of InputSource instances.
     */
    open func setImageInputs(_ inputs: [InputSource]) {
        self.images = inputs
        self.pageControl.numberOfPages = inputs.count

        // in circular mode we add dummy first and last image to enable smooth scrolling
        if circular && images.count > 1 {
            var scImages = [InputSource]()

            if let last = images.last {
                scImages.append(last)
            }
            scImages += images
            if let first = images.first {
                scImages.append(first)
            }

            self.scrollViewImages = scImages
        } else {
            self.scrollViewImages = images
        }

        reloadScrollView()
        layoutScrollView()
        layoutPageControl()
        setTimerIfNeeded()
    }

    // MARK: paging methods

    /**
     Change the current page
     - parameter newPage: new page
     - parameter animated: true if animate the change
     */
    open func setCurrentPage(_ newPage: Int, animated: Bool) {
        var pageOffset = newPage
        if circular && (scrollViewImages.count > 1) {
            pageOffset += 1
        }

        self.setScrollViewPage(pageOffset, animated: animated)
    }

    /**
     Change the scroll view page. This may differ from `setCurrentPage` as circular slider has two more dummy pages at indexes 0 and n-1 to provide fluent scrolling between first and last item.
     - parameter newScrollViewPage: new scroll view page
     - parameter animated: true if animate the change
     */
    open func setScrollViewPage(_ newScrollViewPage: Int, animated: Bool) {
        if scrollViewPage < scrollViewImages.count {
            self.scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width * CGFloat(newScrollViewPage), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: animated)
            self.setCurrentPageForScrollViewPage(newScrollViewPage)
        }
    }

    fileprivate func setTimerIfNeeded() {
        if slideshowInterval > 0 && scrollViewImages.count > 1 && slideshowTimer == nil {
            slideshowTimer = Timer.scheduledTimer(timeInterval: slideshowInterval, target: self, selector: #selector(ImageSlideshow.slideshowTick(_:)), userInfo: nil, repeats: true)
        }
    }

    @objc func slideshowTick(_ timer: Timer) {
        let page = scrollView.frame.size.width > 0 ? Int(scrollView.contentOffset.x / scrollView.frame.size.width) : 0
        var nextPage = page + 1

        if !circular && page == scrollViewImages.count - 1 {
            nextPage = 0
        }

        self.setScrollViewPage(nextPage, animated: true)
    }

    fileprivate func setCurrentPageForScrollViewPage(_ page: Int) {
        if scrollViewPage != page {
            // current page has changed, zoom out this image
            if slideshowItems.count > scrollViewPage {
                slideshowItems[scrollViewPage].zoomOut()
            }
        }

        if page != scrollViewPage {
            loadImages(for: page)
        }
        scrollViewPage = page
        currentPage = currentPageForScrollViewPage(page)
    }
    
    fileprivate func currentPageForScrollViewPage(_ page: Int) -> Int {
        if circular {
            if page == 0 {
                // first page contains the last image
                return Int(images.count) - 1
            } else if page == scrollViewImages.count - 1 {
                // last page contains the first image
                return 0
            } else {
                return page - 1
            }
        } else {
            return page
        }
    }

    /// Stops slideshow timer
    open func pauseTimer() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }

    /// Restarts slideshow timer
    open func unpauseTimer() {
        setTimerIfNeeded()
    }

    @available(*, deprecated, message: "use pauseTimer instead")
    open func pauseTimerIfNeeded() {
        self.pauseTimer()
    }

    @available(*, deprecated, message: "use unpauseTimer instead")
    open func unpauseTimerIfNeeded() {
        self.unpauseTimer()
    }

    /**
     Open full screen slideshow
     - parameter controller: Controller to present the full screen controller from
     - returns: FullScreenSlideshowViewController instance
     */
    @discardableResult
    open func presentFullScreenController(from controller: UIViewController) -> FullScreenSlideshowViewController {
        let fullscreen = FullScreenSlideshowViewController()
        fullscreen.pageSelected = {[weak self] (page: Int) in
            self?.setCurrentPage(page, animated: false)
        }

        fullscreen.initialPage = self.currentPage
        fullscreen.inputs = self.images
        slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: self, slideshowController: fullscreen)
        fullscreen.transitioningDelegate = slideshowTransitioningDelegate
        controller.present(fullscreen, animated: true, completion: nil)

        return fullscreen
    }

    @objc private func pageControlValueChanged() {
        self.setCurrentPage(pageControl.currentPage, animated: true)
    }
}

extension ImageSlideshow: UIScrollViewDelegate {

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if slideshowTimer?.isValid != nil {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
        }

        setTimerIfNeeded()
        willBeginDragging?()
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setCurrentPageForScrollViewPage(primaryVisiblePage)
        didEndDecelerating?()
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if circular {
            let regularContentOffset = scrollView.frame.size.width * CGFloat(images.count)

            if scrollView.contentOffset.x >= scrollView.frame.size.width * CGFloat(images.count + 1) {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - regularContentOffset, y: 0)
            } else if scrollView.contentOffset.x < 0 {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + regularContentOffset, y: 0)
            }
        }

        pageControl.currentPage = currentPageForScrollViewPage(primaryVisiblePage)
    }
}
