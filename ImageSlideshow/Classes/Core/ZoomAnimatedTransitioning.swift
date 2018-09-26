//
//  ZoomAnimatedTransitioning.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//
//

import UIKit

@objcMembers
open class ZoomAnimatedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    /// parent image view used for animated transition
    open var referenceImageView: UIImageView?
    /// parent slideshow view used for animated transition
    open weak var referenceSlideshowView: ImageSlideshow?

    // must be weak because FullScreenSlideshowViewController has strong reference to its transitioning delegate
    weak var referenceSlideshowController: FullScreenSlideshowViewController?

    var referenceSlideshowViewFrame: CGRect?
    var gestureRecognizer: UIPanGestureRecognizer!
    fileprivate var interactionController: UIPercentDrivenInteractiveTransition?

    /// Enables or disables swipe-to-dismiss interactive transition
    open var slideToDismissEnabled: Bool = true

    /**
        Init the transitioning delegate with a source ImageSlideshow
        - parameter slideshowView: ImageSlideshow instance to animate the transition from
        - parameter slideshowController: FullScreenViewController instance to animate the transition to
     */
    public init(slideshowView: ImageSlideshow, slideshowController: FullScreenSlideshowViewController) {
        self.referenceSlideshowView = slideshowView
        self.referenceSlideshowController = slideshowController

        super.init()

        initialize()
    }

    /**
        Init the transitioning delegate with a source ImageView
        - parameter imageView: UIImageView instance to animate the transition from
        - parameter slideshowController: FullScreenViewController instance to animate the transition to
     */
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
        UIApplication.shared.keyWindow?.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let referenceSlideshowController = referenceSlideshowController else {
            return
        }

        let percent = min(max(abs(gesture.translation(in: gesture.view!).y) / 200.0, 0.0), 1.0)

        if gesture.state == .began {
            interactionController = UIPercentDrivenInteractiveTransition()
            referenceSlideshowController.dismiss(animated: true, completion: nil)
        } else if gesture.state == .changed {
            interactionController?.update(percent)
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            let velocity = gesture.velocity(in: referenceSlideshowView)

            if abs(velocity.y) > 500 {
                if let pageSelected = referenceSlideshowController.pageSelected {
                    pageSelected(referenceSlideshowController.slideshow.currentPage)
                }

                interactionController?.finish()
            } else if percent > 0.5 {
                if let pageSelected = referenceSlideshowController.pageSelected {
                    pageSelected(referenceSlideshowController.slideshow.currentPage)
                }

                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }

            interactionController = nil
        }
    }

    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let reference = referenceSlideshowView {
            return ZoomInAnimator(referenceSlideshowView: reference, parent: self)
        } else if let reference = referenceImageView {
            return ZoomInAnimator(referenceImageView: reference, parent: self)
        } else {
            return nil
        }
    }

    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let reference = referenceSlideshowView {
            return ZoomOutAnimator(referenceSlideshowView: reference, parent: self)
        } else if let reference = referenceImageView {
            return ZoomOutAnimator(referenceImageView: reference, parent: self)
        } else {
            return nil
        }
    }

    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

extension ZoomAnimatedTransitioningDelegate: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        if !slideToDismissEnabled {
            return false
        }

        if let currentItem = referenceSlideshowController?.slideshow.currentSlideshowItem, currentItem.isZoomed() {
            return false
        }

        if let view = gestureRecognizer.view {
            let velocity = gestureRecognizer.velocity(in: view)
            return abs(velocity.x) < abs(velocity.y)
        }

        return true
    }
}

@objcMembers
class ZoomAnimator: NSObject {

    var referenceImageView: UIImageView?
    var referenceSlideshowView: ImageSlideshow?
    var parent: ZoomAnimatedTransitioningDelegate

    init(referenceSlideshowView: ImageSlideshow, parent: ZoomAnimatedTransitioningDelegate) {
        self.referenceSlideshowView = referenceSlideshowView
        self.referenceImageView = referenceSlideshowView.currentSlideshowItem?.imageView
        self.parent = parent
        super.init()
    }

    init(referenceImageView: UIImageView, parent: ZoomAnimatedTransitioningDelegate) {
        self.referenceImageView = referenceImageView
        self.parent = parent
        super.init()
    }
}

@objcMembers
class ZoomInAnimator: ZoomAnimator, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Pauses slideshow
        self.referenceSlideshowView?.pauseTimer()

        let containerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!

        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? FullScreenSlideshowViewController else {
            return
        }

        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)

        let transitionBackgroundView = UIView(frame: containerView.frame)
        transitionBackgroundView.backgroundColor = toViewController.backgroundColor
        containerView.addSubview(transitionBackgroundView)

        #if swift(>=4.2)
        containerView.sendSubviewToBack(transitionBackgroundView)
        #else
        containerView.sendSubview(toBack: transitionBackgroundView)
        #endif

        
        let finalFrame = toViewController.view.frame

        var transitionView: UIImageView?
        var transitionViewFinalFrame = finalFrame
        if let referenceImageView = referenceImageView {
            transitionView = UIImageView(image: referenceImageView.image)
            transitionView!.contentMode = UIViewContentMode.scaleAspectFill
            transitionView!.clipsToBounds = true
            transitionView!.frame = containerView.convert(referenceImageView.bounds, from: referenceImageView)
            containerView.addSubview(transitionView!)
            self.parent.referenceSlideshowViewFrame = transitionView!.frame

            referenceImageView.alpha = 0

            if let image = referenceImageView.image {
                transitionViewFinalFrame = image.tgr_aspectFitRectForSize(finalFrame.size)
            }
        }

        if let item = toViewController.slideshow.currentSlideshowItem, item.zoomInInitially {
            transitionViewFinalFrame.size = CGSize(width: transitionViewFinalFrame.size.width * item.maximumZoomScale, height: transitionViewFinalFrame.size.height * item.maximumZoomScale)
        }

        let duration: TimeInterval = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, delay:0, usingSpringWithDamping:0.7, initialSpringVelocity:0, options: UIViewAnimationOptions.curveLinear, animations: {
            fromViewController.view.alpha = 0
            transitionView?.frame = transitionViewFinalFrame
            transitionView?.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }, completion: {[ref = self.referenceImageView] _ in
            fromViewController.view.alpha = 1
            ref?.alpha = 1
            transitionView?.removeFromSuperview()
            transitionBackgroundView.removeFromSuperview()
            containerView.addSubview(toViewController.view)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class ZoomOutAnimator: ZoomAnimator, UIViewControllerAnimatedTransitioning {

    private var animatorForCurrentTransition: UIViewImplicitlyAnimating?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    @available(iOS 10.0, *)
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // as per documentation, the same object should be returned for the ongoing transition
        if let animatorForCurrentSession = animatorForCurrentTransition {
            return animatorForCurrentSession
        }
        
        let params = animationParams(using: transitionContext)

        let animator = UIViewPropertyAnimator(duration: params.0, curve: .linear, animations: params.1)
        animator.addCompletion(params.2)
        animatorForCurrentTransition = animator

        return animator
    }

    private func animationParams(using transitionContext: UIViewControllerContextTransitioning) -> (TimeInterval, () -> (), (Any) -> ()) {
        let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? FullScreenSlideshowViewController else {
            fatalError("Transition not used with FullScreenSlideshowViewController")
        }

        let containerView = transitionContext.containerView

        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        toViewController.view.alpha = 0
        containerView.addSubview(toViewController.view)
        #if swift(>=4.2)
        containerView.sendSubviewToBack(toViewController.view)
        #else
        containerView.sendSubview(toBack: toViewController.view)
        #endif
        var transitionViewInitialFrame: CGRect
        if let currentSlideshowItem = fromViewController.slideshow.currentSlideshowItem {
            if let image = currentSlideshowItem.imageView.image {
                transitionViewInitialFrame = image.tgr_aspectFitRectForSize(currentSlideshowItem.imageView.frame.size)
            } else {
                transitionViewInitialFrame = currentSlideshowItem.imageView.frame
            }
            transitionViewInitialFrame = containerView.convert(transitionViewInitialFrame, from: currentSlideshowItem)
        } else {
            transitionViewInitialFrame = fromViewController.slideshow.frame
        }

        var transitionViewFinalFrame: CGRect
        if let referenceImageView = referenceImageView {
            referenceImageView.alpha = 0

            let referenceSlideshowViewFrame = containerView.convert(referenceImageView.bounds, from: referenceImageView)
            transitionViewFinalFrame = referenceSlideshowViewFrame

            // do a frame scaling when AspectFit content mode enabled
            if fromViewController.slideshow.currentSlideshowItem?.imageView.image != nil && referenceImageView.contentMode == UIViewContentMode.scaleAspectFit {
                transitionViewFinalFrame = containerView.convert(referenceImageView.aspectToFitFrame(), from: referenceImageView)
            }

            // fixes the problem when the referenceSlideshowViewFrame was shifted during change of the status bar hidden state
            if UIApplication.shared.isStatusBarHidden && !toViewController.prefersStatusBarHidden && referenceSlideshowViewFrame.origin.y != parent.referenceSlideshowViewFrame?.origin.y {
                transitionViewFinalFrame = transitionViewFinalFrame.offsetBy(dx: 0, dy: 20)
            }
        } else {
            transitionViewFinalFrame = referenceSlideshowView?.frame ?? CGRect.zero
        }

        let transitionBackgroundView = UIView(frame: containerView.frame)
        transitionBackgroundView.backgroundColor = fromViewController.backgroundColor
        containerView.addSubview(transitionBackgroundView)
        #if swift(>=4.2)
        containerView.sendSubviewToBack(transitionBackgroundView)
        #else
        containerView.sendSubview(toBack: transitionBackgroundView)
        #endif

        let transitionView: UIImageView = UIImageView(image: fromViewController.slideshow.currentSlideshowItem?.imageView.image)
        transitionView.contentMode = UIViewContentMode.scaleAspectFill
        transitionView.clipsToBounds = true
        transitionView.frame = transitionViewInitialFrame
        containerView.addSubview(transitionView)
        fromViewController.view.isHidden = true

        let duration: TimeInterval = transitionDuration(using: transitionContext)
        let animations = {
            toViewController.view.alpha = 1
            transitionView.frame = transitionViewFinalFrame
        }
        let completion = { (_: Any) in
            let completed = !transitionContext.transitionWasCancelled
            self.referenceImageView?.alpha = 1

            if completed {
                fromViewController.view.removeFromSuperview()
                UIApplication.shared.keyWindow?.removeGestureRecognizer(self.parent.gestureRecognizer)
                // Unpauses slideshow
                self.referenceSlideshowView?.unpauseTimer()
            } else {
                fromViewController.view.isHidden = false
            }

            transitionView.removeFromSuperview()
            transitionBackgroundView.removeFromSuperview()

            self.animatorForCurrentTransition = nil

            transitionContext.completeTransition(completed)
        }

        return (duration, animations, completion)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // Working around iOS 10+ breaking change requiring to use UIPropertyAnimator for proper interactive transition instead of UIView.animate
        if #available(iOS 10.0, *) {
            interruptibleAnimator(using: transitionContext).startAnimation()
        } else {
            let params = animationParams(using: transitionContext)
            UIView.animate(withDuration: params.0, delay: 0, options: UIViewAnimationOptions(), animations: params.1, completion: params.2)
        }
    }
}
