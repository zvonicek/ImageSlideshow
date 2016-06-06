//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit

public class FullScreenSlideshowViewController: UIViewController {
    
    public var slideshow: ImageSlideshow = {
        let slideshow = ImageSlideshow()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.ScaleAspectFit
        slideshow.pageControlPosition = PageControlPosition.InsideScrollView
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        return slideshow
    }()
    
    public var closeButton = UIButton()
    public var pageSelected: ((page: Int) -> ())?
    
    /// Index of initial image
    public var initialImageIndex: Int = 0
    public var inputs: [InputSource]?
    
    /// Background color
    public var backgroundColor = UIColor.blackColor()
    
    /// Enables/disable zoom
    public var zoomEnabled = true {
        didSet {
            slideshow.zoomEnabled = zoomEnabled
        }
    }
    
    private var isInit = true
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        
        // slideshow view configuration
        slideshow.frame = view.frame
        slideshow.backgroundColor = backgroundColor
        
        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }
        
        slideshow.frame = view.frame
        view.addSubview(slideshow);
        
        // close button configuration
        closeButton.frame = CGRectMake(10, 20, 40, 40)
        closeButton.setImage(UIImage(named: "Frameworks/ImageSlideshow.framework/ImageSlideshow.bundle/ic_cross_white@2x"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(closeButton)
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInit {
            isInit = false
            slideshow.setScrollViewPage(initialImageIndex, animated: false)
        }
    }
    
    func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(page: slideshow.scrollViewPage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
