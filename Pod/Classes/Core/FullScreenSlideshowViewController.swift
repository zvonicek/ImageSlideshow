//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit

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
    open var pageSelected: ((_ page: Int) -> ())?
    
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
    
    fileprivate var isInit = true
    
    override open func viewDidLoad() {
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
        closeButton.frame = CGRect(x: 10, y: 20, width: 40, height: 40)
        closeButton.setImage(UIImage(named: "Frameworks/ImageSlideshow.framework/ImageSlideshow.bundle/ic_cross_white@2x"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControlEvents.touchUpInside)
        view.addSubview(closeButton)
    }
    
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isInit {
            isInit = false
            slideshow.setCurrentPage(initialPage, animated: false)
        }
    }
    
    func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
