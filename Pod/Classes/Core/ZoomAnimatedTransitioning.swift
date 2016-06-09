//
//  ZoomAnimatedTransitioning.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//
//

import UIKit

public class ZoomAnimatedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    var referenceImageView: UIImageView?
    var referenceSlideshowView: ImageSlideshow?
    let referenceSlideshowController: FullScreenSlideshowViewController
    var referenceSlideshowViewFrame: CGRect?
    var gestureRecognizer: UIPanGestureRecognizer!
    private var interactionController: UIPercentDrivenInteractiveTransition?
    
    /// Enables or disables swipe-to-dismiss
    public var slideToDismissEnabled: Bool = true
    
    public init(slideshowView: ImageSlideshow, slideshowController: FullScreenSlideshowViewController) {
        self.referenceSlideshowView = slideshowView
        self.referenceSlideshowController = slideshowController
        
        super.init()
        
        initialize()
    }

    public init(imageView: UIImageView, slideshowController: FullScreenSlideshowViewController) {
        self.referenceImageView = imageView
        self.referenceSlideshowController = slideshowController

        super.init()

        initialize()
    }

    func initialize() {
        // Pan gesture recognizer for interactive dismiss
        gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ZoomAnimatedTransitioningDelegate.handleSwipe(_:)))
        gestureRecognizer.delegate = self
        // Append it to a window otherwise it will be canceled during the transition
        UIApplication.sharedApplication().keyWindow?.addGestureRecognizer(gestureRecognizer)
    }
    
    func handleSwipe(gesture: UIPanGestureRecognizer) {
        let percent = min(max(fabs(gesture.translationInView(gesture.view!).y) / 200.0, 0.0), 1.0)
        
        if gesture.state == .Began {
            interactionController = UIPercentDrivenInteractiveTransition()
            referenceSlideshowController.dismissViewControllerAnimated(true, completion: nil)
        } else if gesture.state == .Changed {
            interactionController?.updateInteractiveTransition(percent)
        } else if gesture.state == .Ended || gesture.state == .Cancelled || gesture.state == .Failed {
            
            let velocity = gesture.velocityInView(referenceSlideshowView)
            
            if fabs(velocity.y) > 500 {
                if let pageSelected = referenceSlideshowController.pageSelected {
                    pageSelected(page: referenceSlideshowController.slideshow.scrollViewPage)
                }
                
                interactionController?.finishInteractiveTransition()
            } else if percent > 0.5 {
                if let pageSelected = referenceSlideshowController.pageSelected {
                    pageSelected(page: referenceSlideshowController.slideshow.scrollViewPage)
                }
                
                interactionController?.finishInteractiveTransition()
                
            } else {
                interactionController?.cancelInteractiveTransition()
            }
            
            interactionController = nil
        }
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let reference = referenceSlideshowView {
            return ZoomInAnimator(referenceSlideshowView: reference, parent: self)
        } else if let reference = referenceImageView {
            return ZoomInAnimator(referenceImageView: reference, parent: self)
        } else {
            return nil;
        }
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let reference = referenceSlideshowView {
            return ZoomOutAnimator(referenceSlideshowView: reference, parent: self)
        } else if let reference = referenceImageView {
            return ZoomOutAnimator(referenceImageView: reference, parent: self)
        } else {
            return nil;
        }
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

extension ZoomAnimatedTransitioningDelegate: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        if !slideToDismissEnabled {
            return false
        }

        if let currentItem = referenceSlideshowController.slideshow.currentSlideshowItem where currentItem.isZoomed() {
            return false
        }
        
        return true
    }
}

class ZoomAnimator: NSObject {

    var referenceImageView: UIImageView
    var referenceSlideshowView: ImageSlideshow?
    var parent: ZoomAnimatedTransitioningDelegate

    init(referenceSlideshowView: ImageSlideshow, parent: ZoomAnimatedTransitioningDelegate) {
        self.referenceSlideshowView = referenceSlideshowView
        self.referenceImageView = referenceSlideshowView.currentSlideshowItem!.imageView
        self.parent = parent
        super.init()
    }

    init(referenceImageView: UIImageView, parent: ZoomAnimatedTransitioningDelegate) {
        self.referenceImageView = referenceImageView
        self.parent = parent
        super.init()
    }
}

class ZoomInAnimator: ZoomAnimator { }

extension ZoomInAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Pauses slideshow
        self.referenceSlideshowView?.pauseTimerIfNeeded()
        
        let containerView = transitionContext.containerView()!
        
        let fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController: FullScreenSlideshowViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! FullScreenSlideshowViewController
        
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        
        let transitionBackgroundView = UIView(frame: containerView.frame)
        transitionBackgroundView.backgroundColor = toViewController.backgroundColor
        containerView.addSubview(transitionBackgroundView)
        containerView.sendSubviewToBack(transitionBackgroundView)
        
        let transitionView: UIImageView = UIImageView(image: referenceImageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = containerView.convertRect(referenceImageView.bounds, fromView: referenceImageView)
        containerView.addSubview(transitionView)
        self.parent.referenceSlideshowViewFrame = transitionView.frame
        
        let finalFrame: CGRect = toViewController.view.frame
        var transitionViewFinalFrame = finalFrame;
        
        if let image = referenceImageView.image {
            transitionViewFinalFrame = image.tgr_aspectFitRectForSize(finalFrame.size)
        }
        
        if let item = toViewController.slideshow.currentSlideshowItem where item.zoomInInitially {
            transitionViewFinalFrame.size = CGSizeMake(transitionViewFinalFrame.size.width * item.maximumZoomScale, transitionViewFinalFrame.size.height * item.maximumZoomScale);
        }
        
        let duration: NSTimeInterval = transitionDuration(transitionContext)
        self.referenceImageView.alpha = 0
        
        UIView.animateWithDuration(duration, delay:0, usingSpringWithDamping:0.7, initialSpringVelocity:0, options: UIViewAnimationOptions.CurveLinear, animations: {
            fromViewController.view.alpha = 0
            transitionView.frame = transitionViewFinalFrame
            transitionView.center = CGPointMake(CGRectGetMidX(finalFrame), CGRectGetMidY(finalFrame))
        }, completion: {(finished: Bool) in
            fromViewController.view.alpha = 1
            transitionView.removeFromSuperview()
            transitionBackgroundView.removeFromSuperview()
            containerView.addSubview(toViewController.view)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}

class ZoomOutAnimator: ZoomAnimator { }

extension ZoomOutAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController: FullScreenSlideshowViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! FullScreenSlideshowViewController
        let containerView = transitionContext.containerView()!
        
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        toViewController.view.alpha = 0
        containerView.addSubview(toViewController.view)
        containerView.sendSubviewToBack(toViewController.view)
        
        var transitionViewInitialFrame = fromViewController.slideshow.currentSlideshowItem!.imageView.frame
        
        if let image = fromViewController.slideshow.currentSlideshowItem!.imageView.image {
            transitionViewInitialFrame = image.tgr_aspectFitRectForSize(fromViewController.slideshow.currentSlideshowItem!.imageView.frame.size)
        }
        
        transitionViewInitialFrame = containerView.convertRect(transitionViewInitialFrame, fromView: fromViewController.slideshow.currentSlideshowItem)
        
        let referenceSlideshowViewFrame = containerView.convertRect(referenceImageView.bounds, fromView: referenceImageView)
        var transitionViewFinalFrame = referenceSlideshowViewFrame
        
        // do a frame scaling when AspectFit content mode enabled
        if fromViewController.slideshow.currentSlideshowItem?.imageView.image != nil && referenceImageView.contentMode == UIViewContentMode.ScaleAspectFit {
            transitionViewFinalFrame = containerView.convertRect(referenceImageView.aspectToFitFrame(), fromView: referenceImageView)
        }
        
        // fixes the problem when the referenceSlideshowViewFrame was shifted during change of the status bar hidden state
        if UIApplication.sharedApplication().statusBarHidden && !toViewController.prefersStatusBarHidden() && referenceSlideshowViewFrame.origin.y != parent.referenceSlideshowViewFrame?.origin.y {
            transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20)
        }
        
        let transitionBackgroundView = UIView(frame: containerView.frame)
        transitionBackgroundView.backgroundColor = fromViewController.backgroundColor
        containerView.addSubview(transitionBackgroundView)
        containerView.sendSubviewToBack(transitionBackgroundView)
        
        let transitionView: UIImageView = UIImageView(image: fromViewController.slideshow.currentSlideshowItem!.imageView.image)
        transitionView.contentMode = UIViewContentMode.ScaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = transitionViewInitialFrame
        containerView.addSubview(transitionView)
        fromViewController.view.hidden = true
        
        let duration: NSTimeInterval = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            toViewController.view.alpha = 1
            transitionView.frame = transitionViewFinalFrame
        }, completion: {(finished: Bool) in
            let completed = !transitionContext.transitionWasCancelled()
            
            if completed {
                self.referenceImageView.alpha = 1
                fromViewController.view.removeFromSuperview()
                UIApplication.sharedApplication().keyWindow?.removeGestureRecognizer(self.parent.gestureRecognizer)
                // Unpauses slideshow
                self.referenceSlideshowView?.unpauseTimerIfNeeded()
            } else {
                fromViewController.view.hidden = false
                self.referenceImageView.alpha = 0
            }
            
            transitionView.removeFromSuperview()
            transitionBackgroundView.removeFromSuperview()
            
            transitionContext.completeTransition(completed)
        })
    }
}