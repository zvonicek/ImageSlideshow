//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//  Copyright (c) 2015 Petr Zvonicek. All rights reserved.
//

import UIKit

public class FullScreenSlideshowViewController: UIViewController {
    
    public var slideshow = ImageSlideshow()
    public lazy var closeButton: UIButton = {
        var closeButton = UIButton()
        closeButton.setImage(UIImage(named: "Frameworks/ImageSlideshow.framework/ImageSlideshow.bundle/cancel30"), forState: UIControlState.Normal)
        return closeButton
    }()
    
    public var pageSelected: ((page: Int) -> ())?
    public var initialPage: Int = 0
    public var inputs: [InputSource]?
    public var urls: [NSURL]?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        slideshow.frame = self.view.frame
        slideshow.backgroundColor = UIColor.blackColor()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.ScaleAspectFit
        slideshow.pageControlPosition = PageControlPosition.InsideScrollView
        slideshow.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }
        
        slideshow.frame = self.view.frame
        slideshow.slideshowInterval = 0
        self.view.addSubview(slideshow);
        
        closeButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 45, 15, 30, 30)
        closeButton.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        closeButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(closeButton)
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override public func viewWillAppear(animated: Bool) {
        slideshow.setScrollViewPage(self.initialPage, animated: false)
    }
    
    func close() {
        if let pageSelected = pageSelected {
            pageSelected(page: slideshow.scrollViewPage)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
