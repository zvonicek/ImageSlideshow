//
//  ImageSlideshow.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import UIKit

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

open class ImageSlideshow: UIView, UIScrollViewDelegate {
    
    open let scrollView = UIScrollView()
    open let pageControl = UIPageControl()
    
    // MARK: - State properties
    
    /// Page control position
    open var pageControlPosition = PageControlPosition.insideScrollView {
        didSet {
            setNeedsLayout()
            layoutScrollView()
        }
    }
    
    /// Current item index
    open fileprivate(set) var currentItemIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentItemIndex;
        }
    }
    
    /// Currenlty displayed slideshow item
    open var currentSlideshowItem: ImageSlideshowItem? {
        if slideshowItems.count > scrollViewPage {
            return slideshowItems[scrollViewPage]
        } else {
            return nil
        }
    }
    
    open fileprivate(set) var scrollViewPage: Int = 0
    open fileprivate(set) var images = [InputSource]()
    open fileprivate(set) var slideshowItems = [ImageSlideshowItem]()
    
    // MARK: - Preferences
    
    /// Enables/disables infinite scrolling between images
    open var circular = true
    
    /// Enables/disables user interactions
    open var draggingEnabled = true {
        didSet {
            self.scrollView.isUserInteractionEnabled = draggingEnabled
        }
    }
    
    /// Enables/disables zoom
    open var zoomEnabled = false
    
    /// Image change interval, zero stops the auto-scrolling
    open var slideshowInterval = 0.0 {
        didSet {
            self.slideshowTimer?.invalidate()
            self.slideshowTimer = nil
            setTimerIfNeeded()
        }
    }
    
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
        addSubview(scrollView)
        
        addSubview(pageControl)
        
        setTimerIfNeeded()
        layoutScrollView()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        if case .hidden = self.pageControlPosition {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = false
        }
        pageControl.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 10)
        pageControl.center = CGPoint(x: frame.size.width / 2, y: frame.size.height - 12.0)
        
        layoutScrollView()
    }
    
    /// updates frame of the scroll view and its inner items
    func layoutScrollView() {
        let scrollViewBottomPadding: CGFloat = pageControlPosition.bottomPadding
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - scrollViewBottomPadding)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(scrollViewImages.count), height: scrollView.frame.size.height)
        
        for (index ,view) in self.slideshowItems.enumerated() {
            
            if !view.zoomInInitially {
                view.zoomOut()
            }
            view.frame = CGRect(x: scrollView.frame.size.width * CGFloat(index), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        }
        
        setCurrentPage(currentItemIndex, animated: false)
    }
    
    /// reloads scroll view with latest slideshowItems
    func reloadScrollView() {
        for view in self.slideshowItems {
            view.removeFromSuperview()
        }
        self.slideshowItems = []
        
        var i = 0
        for image in scrollViewImages {
            let item = ImageSlideshowItem(image: image, zoomEnabled: self.zoomEnabled)
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
    }
    
    // MARK: - Image setting
    
    open func setImageInputs(_ inputs: [InputSource]) {
        self.images = inputs
        self.pageControl.numberOfPages = inputs.count;
        
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
            self.scrollViewImages = images;
        }
        
        reloadScrollView()
        layoutScrollView()
        setTimerIfNeeded()
    }
    
    // MARK: paging methods
    
    open func setCurrentPage(_ currentPage: Int, animated: Bool) {
        var pageOffset = currentPage
        if circular {
            pageOffset += 1
        }
        
        self.setScrollViewPage(pageOffset, animated: animated)
    }
    
    open func setScrollViewPage(_ scrollViewPage: Int, animated: Bool) {
        if scrollViewPage < scrollViewImages.count {
            self.scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width * CGFloat(scrollViewPage), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: animated)
            self.setCurrentPageForScrollViewPage(scrollViewPage)
        }
    }
    
    fileprivate func setTimerIfNeeded() {
        if slideshowInterval > 0 && scrollViewImages.count > 1 && slideshowTimer == nil {
            slideshowTimer = Timer.scheduledTimer(timeInterval: slideshowInterval, target: self, selector: #selector(ImageSlideshow.slideshowTick(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func slideshowTick(_ timer: Timer) {
        
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        var nextPage = page + 1
        
        if !circular && page == scrollViewImages.count - 1 {
            nextPage = 0
        }
        
        self.scrollView.scrollRectToVisible(CGRect(x: scrollView.frame.size.width * CGFloat(nextPage), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height), animated: true)
        
        self.setCurrentPageForScrollViewPage(nextPage);
    }
    
    open func setCurrentPageForScrollViewPage(_ page: Int) {
        if scrollViewPage != page {
            // current page has changed, zoom out this image
            if slideshowItems.count > scrollViewPage {
                slideshowItems[scrollViewPage].zoomOut()
            }
        }
        
        scrollViewPage = page
        
        if circular {
            if page == 0 {
                // first page contains the last image
                currentItemIndex = Int(images.count) - 1
            } else if page == scrollViewImages.count - 1 {
                // last page contains the first image
                currentItemIndex = 0
            } else {
                currentItemIndex = page - 1
            }
        } else {
            currentItemIndex = page
        }
    }
    
    /// Stops slideshow timer
    open func pauseTimerIfNeeded() {
        slideshowTimer?.invalidate()
        slideshowTimer = nil
    }
    
    /// Restarts slideshow timer
    open func unpauseTimerIfNeeded() {
        setTimerIfNeeded()
    }
    
    // MARK: UIScrollViewDelegate
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if slideshowTimer?.isValid != nil {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
        }
        
        setTimerIfNeeded()
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        setCurrentPageForScrollViewPage(page);
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if circular {
            let regularContentOffset = scrollView.frame.size.width * CGFloat(images.count)
            
            if (scrollView.contentOffset.x >= scrollView.frame.size.width * CGFloat(images.count + 1)) {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - regularContentOffset, y: 0)
            } else if (scrollView.contentOffset.x < 0) {
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x + regularContentOffset, y: 0)
            }
        }
    }
}
