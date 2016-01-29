//
//  ZoomAnimatedTransitioning.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//
//

import UIKit

public class ZoomAnimatedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    let referenceSlideshowView: ImageSlideshow
    var referenceSlideshowViewFrame: CGRect?
    
    public init(slideshowView: ImageSlideshow) {
        self.referenceSlideshowView = slideshowView
        super.init()
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomAnimatedTransitioning(referenceSlideshowView: referenceSlideshowView, parent: self)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomAnimatedTransitioning(referenceSlideshowView: referenceSlideshowView, parent: self)
    }
}

class ZoomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var referenceSlideshowView: ImageSlideshow
    var parent: ZoomAnimatedTransitioningDelegate
    
    init(referenceSlideshowView: ImageSlideshow, parent: ZoomAnimatedTransitioningDelegate) {
        self.referenceSlideshowView = referenceSlideshowView
        self.parent = parent
        super.init()
    }
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        let viewController: UIViewController = transitionContext!.viewControllerForKey(UITransitionContextToViewControllerKey)!
        return viewController.isBeingPresented() ? 0.5 : 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let viewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        if viewController.isBeingPresented() {
            self.animateZoomInTransition(transitionContext)
        } else {
            self.animateZoomOutTransition(transitionContext)
        }
    }
    
    func animateZoomInTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController: FullScreenSlideshowViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! FullScreenSlideshowViewController
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        let transitionBackgroundView = UIView(frame: transitionContext.containerView()!.frame)
        transitionBackgroundView.backgroundColor = toViewController.backgroundColor
        transitionContext.containerView()!.addSubview(transitionBackgroundView)
        transitionContext.containerView()!.sendSubviewToBack(transitionBackgroundView)
        
        let transitionView: UIImageView = UIImageView(image: self.referenceSlideshowView.currentSlideshowItem!.imageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = transitionContext.containerView()!.convertRect(self.referenceSlideshowView.currentSlideshowItem!.bounds, fromView: self.referenceSlideshowView.currentSlideshowItem)
        transitionContext.containerView()!.addSubview(transitionView)
        self.parent.referenceSlideshowViewFrame = transitionView.frame
        
        let finalFrame: CGRect = toViewController.view.frame
        var transitionViewFinalFrame = finalFrame;
        if let image = self.referenceSlideshowView.currentSlideshowItem!.imageView.image {
            transitionViewFinalFrame = image.tgr_aspectFitRectForSize(finalFrame.size)
        }
        if let item = toViewController.slideshow.currentSlideshowItem where item.zoomInInitially {
            transitionViewFinalFrame.size = CGSizeMake(transitionViewFinalFrame.size.width * item.maximumZoomScale, transitionViewFinalFrame.size.height * item.maximumZoomScale);
        }
        
        let duration: NSTimeInterval = self.transitionDuration(transitionContext)
        self.referenceSlideshowView.alpha = 0
        
        UIView.animateWithDuration(duration, delay:0, usingSpringWithDamping:0.7, initialSpringVelocity:0, options: UIViewAnimationOptions.CurveLinear, animations: {
            fromViewController.view.alpha = 0
            transitionView.frame = transitionViewFinalFrame
            transitionView.center = CGPointMake(CGRectGetMidX(finalFrame), CGRectGetMidY(finalFrame))
            }, completion: {(finished: Bool) in
                fromViewController.view.alpha = 1
                transitionView.removeFromSuperview()
                transitionBackgroundView.removeFromSuperview()
                transitionContext.containerView()!.addSubview(toViewController.view)
                transitionContext.completeTransition(true)
        })
    }
    
    func animateZoomOutTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController: FullScreenSlideshowViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! FullScreenSlideshowViewController
        
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.view.alpha = 0
        transitionContext.containerView()!.addSubview(toViewController.view)
        transitionContext.containerView()!.sendSubviewToBack(toViewController.view)
        
        var transitionViewInitialFrame = fromViewController.slideshow.currentSlideshowItem!.imageView.frame
        if let image = fromViewController.slideshow.currentSlideshowItem!.imageView.image {
            transitionViewInitialFrame = image.tgr_aspectFitRectForSize(fromViewController.slideshow.currentSlideshowItem!.imageView.frame.size)
        }
        transitionViewInitialFrame = transitionContext.containerView()!.convertRect(transitionViewInitialFrame, fromView: fromViewController.slideshow.currentSlideshowItem)
        
        let referenceImageView = self.referenceSlideshowView.currentSlideshowItem!.imageView
        let referenceSlideshowViewFrame = transitionContext.containerView()!.convertRect(self.referenceSlideshowView.scrollView.bounds, fromView: self.referenceSlideshowView.scrollView)
        var transitionViewFinalFrame = referenceSlideshowViewFrame
        
        // do a frame scaling when AspectFit content mode enabled
        if let image = fromViewController.slideshow.currentSlideshowItem!.imageView.image where self.referenceSlideshowView.contentScaleMode == UIViewContentMode.ScaleAspectFit {
            transitionViewFinalFrame = transitionContext.containerView()!.convertRect(frameForImage(image, inImageViewAspectFit: referenceImageView), fromView: referenceImageView)
        }
        
        // fixes the problem when the referenceSlideshowViewFrame was shifted during change of the status bar hidden state
        if UIApplication.sharedApplication().statusBarHidden && !toViewController.prefersStatusBarHidden() && referenceSlideshowViewFrame.origin.y != parent.referenceSlideshowViewFrame?.origin.y {
            transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20)
        }
        
        let transitionBackgroundView = UIView(frame: transitionContext.containerView()!.frame)
        transitionBackgroundView.backgroundColor = fromViewController.backgroundColor
        transitionContext.containerView()!.addSubview(transitionBackgroundView)
        transitionContext.containerView()!.sendSubviewToBack(transitionBackgroundView)
        
        let transitionView: UIImageView = UIImageView(image: fromViewController.slideshow.currentSlideshowItem!.imageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = transitionViewInitialFrame
        transitionContext.containerView()!.addSubview(transitionView)
        fromViewController.view.removeFromSuperview()
        let duration: NSTimeInterval = self.transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            toViewController.view.alpha = 1
            transitionView.frame = transitionViewFinalFrame
            }, completion: {(finished: Bool) in
                self.referenceSlideshowView.alpha = 1
                transitionView.removeFromSuperview()
                transitionBackgroundView.removeFromSuperview()
                transitionContext.completeTransition(true)
        })
    }
    
    func frameForImage(image: UIImage, inImageViewAspectFit imageView: UIImageView) -> CGRect {
        let imageRatio: CGFloat = image.size.width / image.size.height
        let viewRatio: CGFloat = imageView.frame.size.width / imageView.frame.size.height
        if imageRatio < viewRatio {
            let scale: CGFloat = imageView.frame.size.height / image.size.height
            let width: CGFloat = scale * image.size.width
            let topLeftX: CGFloat = (imageView.frame.size.width - width) * 0.5
            return CGRectMake(topLeftX, 0, width, imageView.frame.size.height)
        }
        else {
            let scale: CGFloat = imageView.frame.size.width / image.size.width
            let height: CGFloat = scale * image.size.height
            let topLeftY: CGFloat = (imageView.frame.size.height - height) * 0.5
            return CGRectMake(0, topLeftY, imageView.frame.size.width, height)
        }
    }
}