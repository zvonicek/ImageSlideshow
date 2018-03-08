//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit

public protocol FullScreenSlideshowViewControllerDelegate : class {
    // The callee should perform any actions required to delete the image. The user has already been prompted to confirm they want to delete it. FullScreenSlideshowViewController takes care of removing it from the image source array.
    func deleteImage(_ controller: FullScreenSlideshowViewController, imageToDelete: InputSource)
}

@objcMembers
open class FullScreenSlideshowViewController: UIViewController {

    open var slideshow: ImageSlideshow = {
        let slideshow = ImageSlideshow()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.pageControlPosition = PageControlPosition.insideScrollView
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        return slideshow
    }()

    /// Close button 
    open var closeButton = UIButton()

    /// Closure called on page selection
    open var pageSelected: ((_ page: Int) -> Void)?

    /// Index of initial image
    open var initialPage: Int = 0

    /// Input sources to 
    open var inputs: [InputSource]?

    /// Background color
    open var backgroundColor = UIColor.black

    /// Enables/disable zoom
    open var zoomEnabled = true {
        didSet {
            slideshow.zoomEnabled = zoomEnabled
        }
    }
    
    /// Actions enable you to delete the current image or to send it via email, SMS etc. Client deletion occurs via the delegate.
    open var showActions: Bool = false // the default is false for backwards compatibility.
    fileprivate var actionButton:UIButton!

    weak var delegate:FullScreenSlideshowViewControllerDelegate?
    var parentDelete:((_ index:Int)->())!
    
    fileprivate var isInit = true
    
    fileprivate let yPadding:CGFloat = 20
    fileprivate let xPadding:CGFloat = 10
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        slideshow.backgroundColor = backgroundColor

        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }

        view.addSubview(slideshow)

        // close button configuration
        closeButton.frame = CGRect(x: xPadding, y: yPadding, width: 40, height: 40)
        closeButton.setImage(UIImage(named: "Frameworks/ImageSlideshow.framework/ImageSlideshow.bundle/ic_cross_white@2x"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControlEvents.touchUpInside)
        view.addSubview(closeButton)
        
        if showActions {
            // For sharing images via email, text messages, and for deleting images.
            actionButton = UIButton(type: .system)
            actionButton.tintColor = .white
            let bundle = Bundle(for: type(of: self))
            let actionImage = UIImage(named: "Action", in: bundle, compatibleWith: nil)!
            actionButton.setImage(actionImage, for: .normal)
            actionButton.sizeToFit()

            actionButton.addTarget(self, action: #selector(actionButtonAction), for: .touchUpInside)
            // `actionButton` positioned in `viewDidLayoutSubviews`-- this accounts for rotation too.
            view.addSubview(actionButton)
        }
    }
    
    // Position the action button at the upper right.
    fileprivate func positionActionButton() {
        actionButton.frame.origin.x = view.frame.maxX - actionButton.frame.width - xPadding
        
        // Without this my eyes don't think it's in the right position.
        let yPaddingExtraFudge:CGFloat = 7
        actionButton.frame.origin.y = yPadding + yPaddingExtraFudge
    }
    
    deinit {
        print("deinit")
    }
    
    @objc fileprivate func actionButtonAction() {
        if let currentImageSource = slideshow.currentSlideshowItem?.image,
            let currentImageView = slideshow.currentSlideshowItem?.imageView,
            let image = currentImageView.image {

            // 8/19/17; It looks like you can't control the order of the actions in the list supplied by this control. See https://stackoverflow.com/questions/19060535/how-to-rearrange-activities-on-a-uiactivityviewcontroller
            // Unfortunately, this means the deletion control occurs off to the right-- and I can't see it w/o scrolling on my iPhone6
            let trashActivity = TrashActivity(withParentVC: self, removeImage: {[unowned self] imageToRemove in
                var updatedImages = self.slideshow.images
                
                // I believe `currentPage` is the correct index into slideshow.images
                let originalPageToRemove = self.slideshow.currentPage
                
                updatedImages.remove(at: originalPageToRemove)
                
                // Reset the image inputs from our newly updated images
                self.slideshow.setImageInputs(updatedImages)
                self.parentDelete(originalPageToRemove)

                // As the client to to remove theirs
                self.delegate?.deleteImage(self, imageToDelete: imageToRemove)
                
                if updatedImages.count == 0 {
                    self.close()
                }
            })
        
            // The UIActivityViewController need a UIImage to allow emailing imaget etc. TrashActivity uses the ImageSource object.
            let activityViewController = UIActivityViewController(activityItems: [image, currentImageSource], applicationActivities: [trashActivity])
            
            activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
                if completed {
                    // Action has been carried out (e.g., image has been deleted), remove selected icons.
                    print("Action has been carried out")
                }
            }
            
            activityViewController.popoverPresentationController?.sourceView = view
            
            present(activityViewController, animated: true, completion: {})
        }
    }

    override open var prefersStatusBarHidden: Bool {
        return true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isInit {
            isInit = false
            slideshow.setCurrentPage(initialPage, animated: false)
        }
    }

    open override func viewDidLayoutSubviews() {
        slideshow.frame = view.frame
        positionActionButton()
    }

    @objc func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }

        dismiss(animated: true, completion: nil)
    }
}
