//
//  ZoomAnimatedTransitioningDelegate.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//  Copyright (c) 2015 Petr Zvonicek. All rights reserved.
//

import UIKit

public class ZoomAnimatedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    let referenceSlideshowView: ImageSlideshow
    
    public init(slideshowView: ImageSlideshow) {
        self.referenceSlideshowView = slideshowView
        super.init()
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomAnimatedTransitioning(referenceSlideshowView: referenceSlideshowView)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomAnimatedTransitioning(referenceSlideshowView: referenceSlideshowView)
    }
    
}