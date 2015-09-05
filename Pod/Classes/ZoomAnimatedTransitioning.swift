//
//  ZoomAnimatedTransitioning.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//  Copyright (c) 2015 Petr Zvonicek. All rights reserved.
//

import UIKit

class ZoomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var referenceSlideshowView: ImageSlideshow
    
    init(referenceSlideshowView: ImageSlideshow) {
        self.referenceSlideshowView = referenceSlideshowView
        super.init()
    }
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        var viewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        return viewController.isBeingPresented() ? 0.5 : 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        var viewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        if viewController.isBeingPresented() {
            self.animateZoomInTransition(transitionContext)
        }
        else {
            self.animateZoomOutTransition(transitionContext)
        }
    }
    
    func animateZoomInTransition(transitionContext: UIViewControllerContextTransitioning) {
        var fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        var toViewController: FullScreenSlideshowViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! FullScreenSlideshowViewController
        var transitionView: UIImageView = UIImageView(image: self.referenceSlideshowView.currentSlideshowItem!.imageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = transitionContext.containerView().convertRect(self.referenceSlideshowView.currentSlideshowItem!.bounds, fromView: self.referenceSlideshowView.currentSlideshowItem)
        transitionContext.containerView().addSubview(transitionView)
        var finalFrame: CGRect = toViewController.slideshow!.scrollView.frame
        var transitionViewFinalFrame: CGRect;
        if let image = self.referenceSlideshowView.currentSlideshowItem!.imageView.image {
            transitionViewFinalFrame = image.tgr_aspectFitRectForSize(finalFrame.size)
        } else {
            transitionViewFinalFrame = finalFrame
        }
        
        var duration: NSTimeInterval = self.transitionDuration(transitionContext)
        self.referenceSlideshowView.alpha = 0
        
        UIView.animateWithDuration(duration, delay:0, usingSpringWithDamping:0.7, initialSpringVelocity:0, options: UIViewAnimationOptions.CurveLinear, animations: {
            fromViewController.view.alpha = 0
            transitionView.frame = transitionViewFinalFrame
            }, completion: {(finished: Bool) in
                fromViewController.view.alpha = 1
                transitionView.removeFromSuperview()
                transitionContext.containerView().addSubview(toViewController.view)
                transitionContext.completeTransition(true)
        })
    }
    
    func animateZoomOutTransition(transitionContext: UIViewControllerContextTransitioning) {
        var toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        var fromViewController: FullScreenSlideshowViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! FullScreenSlideshowViewController
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.view.alpha = 0
        transitionContext.containerView().addSubview(toViewController.view)
        transitionContext.containerView().sendSubviewToBack(toViewController.view)
        var transitionViewInitialFrame: CGRect
        if let image = fromViewController.slideshow!.currentSlideshowItem!.imageView.image {
            transitionViewInitialFrame = image.tgr_aspectFitRectForSize(fromViewController.slideshow!.currentSlideshowItem!.imageView.frame.size)
        } else {
            transitionViewInitialFrame = fromViewController.slideshow!.currentSlideshowItem!.imageView.frame
        }
        transitionViewInitialFrame = transitionContext.containerView().convertRect(transitionViewInitialFrame, fromView: fromViewController.slideshow!.currentSlideshowItem)
        
        // TODO: do this only when aspect fit
        var transitionViewFinalFrame: CGRect = transitionContext.containerView().convertRect(self.referenceSlideshowView.scrollView.bounds, fromView: self.referenceSlideshowView.scrollView)
        if let image = fromViewController.slideshow!.currentSlideshowItem!.imageView.image {
            transitionViewFinalFrame = transitionContext.containerView().convertRect(frameForImage(image, inImageViewAspectFit: self.referenceSlideshowView.currentSlideshowItem!.imageView), fromView: self.referenceSlideshowView.currentSlideshowItem!.imageView)
        } else {
            transitionViewFinalFrame = self.referenceSlideshowView.currentSlideshowItem!.imageView.frame
        }
        
//        if UIApplication.sharedApplication().statusBarHidden && !toViewController.prefersStatusBarHidden() {
//            transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20)
//        }
        var transitionView: UIImageView = UIImageView(image: fromViewController.slideshow!.currentSlideshowItem!.imageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = transitionViewInitialFrame
        transitionContext.containerView().addSubview(transitionView)
        fromViewController.view.removeFromSuperview()
        var duration: NSTimeInterval = self.transitionDuration(transitionContext)
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            toViewController.view.alpha = 1
            transitionView.frame = transitionViewFinalFrame
            }, completion: {(finished: Bool) in
                self.referenceSlideshowView.alpha = 1
                transitionView.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
    }
    
    func frameForImage(image: UIImage, inImageViewAspectFit imageView: UIImageView) -> CGRect {
        var imageRatio: CGFloat = image.size.width / image.size.height
        var viewRatio: CGFloat = imageView.frame.size.width / imageView.frame.size.height
        if imageRatio < viewRatio {
            var scale: CGFloat = imageView.frame.size.height / image.size.height
            var width: CGFloat = scale * image.size.width
            var topLeftX: CGFloat = (imageView.frame.size.width - width) * 0.5
            return CGRectMake(topLeftX, 0, width, imageView.frame.size.height)
        }
        else {
            var scale: CGFloat = imageView.frame.size.width / image.size.width
            var height: CGFloat = scale * image.size.height
            var topLeftY: CGFloat = (imageView.frame.size.height - height) * 0.5
            return CGRectMake(0, topLeftY, imageView.frame.size.width, height)
        }
    }
}