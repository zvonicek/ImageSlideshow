//
//  ZoomablePhotoView.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import UIKit

/// Used to wrap a single slideshow item and allow zooming on it
open class ImageSlideshowItem: UIScrollView, UIScrollViewDelegate {

    /// Image view to hold the image
    open let imageView = UIImageView()

    /// Activity indicator shown during image loading, when nil there won't be shown any
    open let activityIndicator: ActivityIndicatorView?

    /// Input Source for the item
    open let image: InputSource

    /// Guesture recognizer to detect double tap to zoom
    open var gestureRecognizer: UITapGestureRecognizer?

    /// Holds if the zoom feature is enabled
    open let zoomEnabled: Bool

    /// If set to true image is initially zoomed in
    open var zoomInInitially = false

    fileprivate var lastFrame = CGRect.zero
    fileprivate var imageReleased = false
    fileprivate var isLoading = false
    fileprivate var singleTapGestureRecognizer: UITapGestureRecognizer?
    fileprivate var loadFailed = false {
        didSet {
            singleTapGestureRecognizer?.isEnabled = loadFailed
            gestureRecognizer?.isEnabled = !loadFailed
        }
    }

    // MARK: - Life cycle

    /**
        Initializes a new ImageSlideshowItem
        - parameter image: Input Source to load the image
        - parameter zoomEnabled: holds if it should be possible to zoom-in the image
    */
    init(image: InputSource, zoomEnabled: Bool, activityIndicator: ActivityIndicatorView? = nil) {
        self.zoomEnabled = zoomEnabled
        self.image = image
        self.activityIndicator = activityIndicator

        super.init(frame: CGRect.null)

        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true

        setPictoCenter()

        // scroll view configuration
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        addSubview(imageView)
        minimumZoomScale = 1.0
        maximumZoomScale = calculateMaximumScale()

        if let activityIndicator = activityIndicator {
            addSubview(activityIndicator.view)
        }

        // tap gesture recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageSlideshowItem.tapZoom))
        tapRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tapRecognizer)
        gestureRecognizer = tapRecognizer

        singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(retryLoadImage))
        singleTapGestureRecognizer!.numberOfTapsRequired = 1
        singleTapGestureRecognizer!.isEnabled = false
        imageView.addGestureRecognizer(singleTapGestureRecognizer!)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if !zoomEnabled {
            imageView.frame.size = frame.size
        } else if !isZoomed() {
            imageView.frame.size = calculatePictureSize()
        }

        if isFullScreen() {
            clearContentInsets()
        } else {
            setPictoCenter()
        }

        self.activityIndicator?.view.center = imageView.center

        // if self.frame was changed and zoomInInitially enabled, zoom in
        if lastFrame != frame && zoomInInitially {
            setZoomScale(maximumZoomScale, animated: false)
        }

        lastFrame = self.frame

        contentSize = imageView.frame.size
        maximumZoomScale = calculateMaximumScale()
    }

    /// Request to load Image Source to Image View
    func loadImage() {
        if self.imageView.image == nil && !isLoading {
            isLoading = true
            imageReleased = false
            activityIndicator?.show()
            image.load(to: self.imageView) { image in
                // set image to nil if there was a release request during the image load
                self.imageView.image = self.imageReleased ? nil : image
                self.activityIndicator?.hide()
                self.loadFailed = image == nil
                self.isLoading = false
            }
        }
    }

    func releaseImage() {
        imageReleased = true
        self.imageView.image = nil
    }

    @objc func retryLoadImage() {
        self.loadImage()
    }

    // MARK: - Image zoom & size

    func isZoomed() -> Bool {
        return self.zoomScale != self.minimumZoomScale
    }

    func zoomOut() {
        self.setZoomScale(minimumZoomScale, animated: false)
    }

    @objc func tapZoom() {
        if isZoomed() {
            self.setZoomScale(minimumZoomScale, animated: true)
        } else {
            self.setZoomScale(maximumZoomScale, animated: true)
        }
    }

    fileprivate func screenSize() -> CGSize {
        return CGSize(width: frame.width, height: frame.height)
    }

    fileprivate func calculatePictureFrame() {
        let boundsSize: CGSize = bounds.size
        var frameToCenter: CGRect = imageView.frame

        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }

        imageView.frame = frameToCenter
    }

    fileprivate func calculatePictureSize() -> CGSize {
        if let image = imageView.image, imageView.contentMode == .scaleAspectFit {
            let picSize = image.size
            let picRatio = picSize.width / picSize.height
            let screenRatio = screenSize().width / screenSize().height

            if picRatio > screenRatio {
                return CGSize(width: screenSize().width, height: screenSize().width / picSize.width * picSize.height)
            } else {
                return CGSize(width: screenSize().height / picSize.height * picSize.width, height: screenSize().height)
            }
        } else {
            return CGSize(width: screenSize().width, height: screenSize().height)
        }
    }

    fileprivate func calculateMaximumScale() -> CGFloat {
        // maximum scale is fixed to 2.0 for now. This may be overriden to perform a more sophisticated computation
        return 2.0
    }

    fileprivate func setPictoCenter() {
        var intendHorizon = (screenSize().width - imageView.frame.width ) / 2
        var intendVertical = (screenSize().height - imageView.frame.height ) / 2
        intendHorizon = intendHorizon > 0 ? intendHorizon : 0
        intendVertical = intendVertical > 0 ? intendVertical : 0
        contentInset = UIEdgeInsets(top: intendVertical, left: intendHorizon, bottom: intendVertical, right: intendHorizon)
    }

    private func isFullScreen() -> Bool {
        return imageView.frame.width >= screenSize().width && imageView.frame.height >= screenSize().height
    }

    func clearContentInsets() {
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    // MARK: UIScrollViewDelegate

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setPictoCenter()
    }

    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomEnabled ? imageView : nil
    }

}
