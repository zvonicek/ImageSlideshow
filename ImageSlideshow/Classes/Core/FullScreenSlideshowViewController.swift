//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit

@objcMembers
open class FullScreenSlideshowViewController: UIViewController {

    open var slideshow: ImageSlideshow = {
        let slideshow = ImageSlideshow()
        slideshow.zoomEnabled = true
        slideshow.isFullScreenSlideShow = true
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        return slideshow
    }()
    
    /// Left Arrow button
    open var leftArrowButton = UIButton()
    
    /// Right Arrow button
    open var rightArrowButton = UIButton()

    /// Close button 
    open var closeButton = UIButton()

    /// Close button frame
    open var closeButtonFrame: CGRect?

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

    fileprivate var hideInfo = true

    fileprivate var isInit = true

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .custom
        if #available(iOS 13.0, *) {
            // Use KVC to set the value to preserve backwards compatiblity with Xcode < 11
            self.setValue(true, forKey: "modalInPresentation")
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        slideshow.backgroundColor = backgroundColor

        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }

        view.addSubview(slideshow)
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapAction))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        slideshow.addGestureRecognizer(singleTapGestureRecognizer)

        updateUI()

        // close button configuration
        closeButton.setImage(UIImage(named: "ic_cross_white", in: .module, compatibleWith: nil), for: UIControlState())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControlEvents.touchUpInside)
        view.addSubview(closeButton)
            
        // left arrow button configuration
        leftArrowButton.setImage(UIImage(named: "arrow-left-64x", in: Bundle(for: type(of: self)), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        leftArrowButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.leftArrowTap(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(leftArrowButton)

        // Right arrow button configuration
        rightArrowButton.setImage(UIImage(named: "arrow-right-64x", in: Bundle(for: type(of: self)), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: UIControlState())
        rightArrowButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.rightArrowTap(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(rightArrowButton)
        leftArrowButton.translatesAutoresizingMaskIntoConstraints = false
        rightArrowButton.translatesAutoresizingMaskIntoConstraints = false
        leftArrowButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        rightArrowButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        leftArrowButton.tintColor = .white
        rightArrowButton.tintColor = .white
        
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        let leadingConstraint = NSLayoutConstraint(item: leftArrowButton, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        let centerLeftConstraint = NSLayoutConstraint(item: leftArrowButton, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)

        let trailingConstraint = NSLayoutConstraint(item: rightArrowButton, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let centerRightConstraint = NSLayoutConstraint(item: rightArrowButton, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        
        
        NSLayoutConstraint.activate([leadingConstraint, centerLeftConstraint, trailingConstraint, centerRightConstraint])
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

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        slideshow.slideshowItems.forEach { $0.cancelPendingLoad() }

        // Prevents broken dismiss transition when image is zoomed in
        slideshow.currentSlideshowItem?.zoomOut()
    }

    open override func viewDidLayoutSubviews() {
        if !isBeingDismissed {
            let safeAreaInsets: UIEdgeInsets
            if #available(iOS 11.0, *) {
                safeAreaInsets = view.safeAreaInsets
            } else {
                safeAreaInsets = UIEdgeInsets.zero
            }

            closeButton.frame = closeButtonFrame ?? CGRect(x: max(10, safeAreaInsets.left), y: max(10, safeAreaInsets.top), width: 40, height: 40)
            closeButton.layer.cornerRadius = 20
        }

        slideshow.frame = view.frame
    }

    func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }

        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func updateUI() {
        closeButton.isHidden = hideInfo
        rightArrowButton.isHidden = hideInfo || slideshow.slideshowItems.count < 2
        leftArrowButton.isHidden = hideInfo || slideshow.slideshowItems.count < 2
        slideshow.hideCaption = hideInfo
    }
    
    @objc private func rightArrowTap(_ sender: UIButton) {
        let nextIndex = slideshow.currentPage + 1
        slideshow.setCurrentPage(nextIndex, animated: true)
    }
    
    @objc private func leftArrowTap(_ sender: UIButton) {
        let nextIndex = slideshow.currentPage - 1
        slideshow.setCurrentPage(nextIndex, animated: true)
    }

    @objc func singleTapAction() {
        hideInfo = !hideInfo
        updateUI()
    }
}
