//
//  ImageSlideshow.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import UIKit

@objc public enum PageControlPosition: Int {
    case Hidden
    case InsideScrollView
    case UnderScrollView
}

public protocol SlideShowDelegate {
    func didStartSliding()
}

public class ImageSlideshow: UIView, UIScrollViewDelegate {
    
    public let scrollView = UIScrollView()
    public let pageControl = CustomPageControl()
    public var slideshowDelegate: SlideShowDelegate?
    
    // state properties
    
    public var pageControlPosition = PageControlPosition.InsideScrollView {
        didSet {
            setNeedsLayout()
            layoutScrollView()
        }
    }
    
    public private(set) var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage;
        }
    }
    
    public var currentSlideshowItem: ImageSlideshowItem? {
        get {
            if (self.slideshowItems.count > self.scrollViewPage) {
                return self.slideshowItems[self.scrollViewPage]
            } else {
                return nil
            }
        }
    }
    
    public private(set) var scrollViewPage: Int = 0
    
    // preferences
    
    public var circular = true
    public var draggingEnabled = true {
        didSet {
            self.scrollView.userInteractionEnabled = draggingEnabled
        }
    }
    public var zoomEnabled = false
    public var slideshowInterval = 0.0 {
        didSet {
            self.slideshowTimer?.invalidate()
            self.slideshowTimer = nil
            setTimerIfNeeded()
        }
    }
    public var contentScaleMode: UIViewContentMode = UIViewContentMode.ScaleAspectFit {
        didSet {
            for view in slideshowItems {
                view.imageView.contentMode = contentScaleMode
            }
        }
    }
    
    private var slideshowTimer: NSTimer?
    public private(set) var images = [InputSource]()
    private var scrollViewImages = [InputSource]()
    public private(set) var slideshowItems = [ImageSlideshowItem]()
    
    var lastPage : CGFloat = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        self.autoresizesSubviews = true
        self.clipsToBounds = true
        
        // scroll view configuration
        scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 47.0)
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        
        let horizontalConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        self.addConstraint(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        self.addConstraint(verticalConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        self.addConstraint(heightConstraint)
        
        setTimerIfNeeded()
        layoutScrollView()
    }
    
    override public func layoutSubviews() {
        pageControl.hidden = pageControlPosition == .Hidden
        pageControl.frame = CGRectMake(0, -200, self.frame.size.width, 20)
        
        var pcPositionPadding : CGFloat = 45
        
        switch UIScreen.mainScreen().bounds.height {
        case 480:
            pcPositionPadding = 58
        case 568 :
            pcPositionPadding = 57
        case 667 :
            pcPositionPadding = 47
        case 736 :
            pcPositionPadding = 35
        default :
            pcPositionPadding = 55
        }
        
        pageControl.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - pcPositionPadding)
        
        layoutScrollView()
    }
    
    /// updates frame of the scroll view and its inner items
    func layoutScrollView() {
        let scrollViewBottomPadding: CGFloat = self.pageControlPosition == .UnderScrollView ? 30.0 : 75.0
        scrollView.frame = CGRectMake(0, 0, self.frame.size.width , self.frame.size.height - scrollViewBottomPadding)
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * CGFloat(scrollViewImages.count), scrollView.frame.size.height)
        
        var i = 0
        for view in self.slideshowItems {
            if !view.zoomInInitially {
                view.zoomOut()
            }
            view.frame = CGRectMake(scrollView.frame.size.width * CGFloat(i), 0, scrollView.frame.size.width, scrollView.frame.size.height)
            i++
        }
        
        setCurrentPage(currentPage, animated: false)
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
            i++
        }
        
        if circular && (scrollViewImages.count > 1) {
            scrollViewPage = 1
            scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: false)
        } else {
            scrollViewPage = 0
        }
    }
    
    // MARK: image setting
    
    public func setImageInputs(inputs: [InputSource]) {
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
        setTimerIfNeeded()
    }
    
    // MARK: paging methods
    
    public func setCurrentPage(currentPage: Int, animated: Bool) {
        var pageOffset = currentPage
        if circular {
            pageOffset += 1
        }
        
        self.setScrollViewPage(pageOffset, animated: animated)
    }
    
    public func setScrollViewPage(scrollViewPage: Int, animated: Bool) {
        if scrollViewPage < scrollViewImages.count {
            self.scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width * CGFloat(scrollViewPage), 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: animated)
            self.setCurrentPageForScrollViewPage(scrollViewPage)
        }
    }
    
    private func setTimerIfNeeded() {
        if slideshowInterval > 0 && scrollViewImages.count > 1 && slideshowTimer == nil {
            slideshowTimer = NSTimer.scheduledTimerWithTimeInterval(slideshowInterval, target: self, selector: "slideshowTick:", userInfo: nil, repeats: true)
        }
    }
    
    func slideshowTick(timer: NSTimer) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        var nextPage = page + 1
        
        if !circular && page == scrollViewImages.count - 1 {
            nextPage = 0
        }
        
        self.scrollView.scrollRectToVisible(CGRectMake(scrollView.frame.size.width * CGFloat(nextPage), 0, scrollView.frame.size.width, scrollView.frame.size.height), animated: true)
        
        self.setCurrentPageForScrollViewPage(nextPage);
    }
    
    public func setCurrentPageForScrollViewPage(page: Int) {
        if (scrollViewPage != page) {
            // current page has changed, zoom out this image
            if (slideshowItems.count > scrollViewPage) {
                slideshowItems[scrollViewPage].zoomOut()
            }
        }
        
        scrollViewPage = page
        
        if (circular) {
            if page == 0 {
                // first page contains the last image
                currentPage = Int(images.count) - 1
            } else if page == scrollViewImages.count - 1 {
                // last page contains the first image
                currentPage = 0
            } else {
                currentPage = page - 1
            }
        } else {
            currentPage = page
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if slideshowTimer?.valid != nil {
            slideshowTimer?.invalidate()
            slideshowTimer = nil
        }
        
        if(slideshowDelegate != nil) {
            slideshowDelegate!.didStartSliding()
        }
        
        setTimerIfNeeded()
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        setCurrentPageForScrollViewPage(page);
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if circular {
            let regularContentOffset = scrollView.frame.size.width * CGFloat(images.count)
            
            if (scrollView.contentOffset.x >= scrollView.frame.size.width * CGFloat(images.count + 1)) {
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - regularContentOffset, 0)
            } else if (scrollView.contentOffset.x < 0) {
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + regularContentOffset, 0)
            }
            
            var previousPage : CGFloat = 0
            let pageWidth = scrollView.frame.size.width
            let fractionalPage = scrollView.contentOffset.x / pageWidth
            
            let page = round(fractionalPage)
            
            if (previousPage != page) {
                if (lastPage != page ) {
                    NSNotificationCenter.defaultCenter().postNotificationName("actionCarousel", object: nil, userInfo: ["message" : page-1])
                    lastPage = page
                }
                // Page has changed, do your thing!
                // ...
                // Finally, update previous page
                previousPage = page
            }
            else if previousPage == 0 && lastPage != CGFloat(images.count ) {
                NSNotificationCenter.defaultCenter().postNotificationName("actionCarousel", object: nil, userInfo: ["message" : images.count - 1])
                lastPage = CGFloat(images.count )
                previousPage = CGFloat(images.count)
            }
        }
    }
}

public class CustomPageControl: UIPageControl {
    //change to needed images names
    let activeImage = UIImage(named: "page_control_active")!
    let inactiveImage = UIImage(named: "page_control_noactive")!
    
    var starPosition: Int = 0 {
        didSet {
            updateDots()
        }
    }
    var plusPosition = 0
    
    let ratio = CGFloat(0.6)
    
    dynamic override public var currentPage: Int {
        didSet {
            updateDots()
        }
    }
    
    override public var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }
    
    private func updateDots() {
        
        pageIndicatorTintColor = UIColor.clearColor()
        currentPageIndicatorTintColor = UIColor.clearColor()
        //backgroundColor = UIColor.clearColor()
        
        for i in 0..<subviews.count {
            let dot = imageViewForSubview(subviews[i])
            if i == currentPage {
                dot.image = activeImage
            }
            else {
                dot.image = inactiveImage
            }
        }
    }
    
    private func imageViewForSubview(view : UIView) -> UIImageView {
        var dot: UIImageView!
        if view.isKindOfClass(UIView) {
            for subview in view.subviews {
                if subview.isKindOfClass(UIImageView) {
                    dot = subview as? UIImageView
                    break
                }
            }
            if dot == nil {
                dot = UIImageView(frame: CGRectMake(0, 0, CGRectGetWidth(view.frame) * 1.1, CGRectGetHeight(view.frame) * ratio))
                dot.contentMode = .ScaleAspectFit
                view.addSubview(dot)
            }
        } else {
            dot = view as? UIImageView
        }
        return dot
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        pageIndicatorTintColor = UIColor.clearColor()
        currentPageIndicatorTintColor = UIColor.clearColor()
        backgroundColor = UIColor.clearColor()
    }
}