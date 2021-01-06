//
//  InputSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import UIKit

/// A protocol that can be adapted by different Input Source providers
@objc public protocol InputSource {
    /**
     Load image from the source to image view.
     - parameter imageView: Image view to load the image into.
     - parameter callback: Callback called after image was set to the image view.
     - parameter image: Image that was set to the image view.
     */
    func load(to imageView: UIImageView, with callback: @escaping (_ image: UIImage?, _ caption: String?, _ captionBottomConstraint: CGFloat, _ showCaptionOnlyInFullScreen: Bool) -> Void)

    /**
     Cancel image load on the image view
     - parameter imageView: Image view that is loading the image
    */
    @objc optional func cancelLoad(on imageView: UIImageView)
}

/// Input Source to load plain UIImage
@objcMembers
open class ImageSource: NSObject, InputSource {
    var image: UIImage
    var caption: String
    var captionBottomConstraint: CGFloat
    var showCaptionOnlyInFullScreen: Bool

    /// Initializes a new Image Source with UIImage
    /// - parameter image: Image to be loaded
    public init(image: UIImage, caption: String = "", captionBottomConstraint: CGFloat = 0, showCaptionOnlyInFullScreen: Bool = false) {
        self.image = image
        self.caption = caption
        self.captionBottomConstraint = captionBottomConstraint
        self.showCaptionOnlyInFullScreen = showCaptionOnlyInFullScreen
    }

    /// Initializes a new Image Source with an image name from the main bundle
    /// - parameter imageString: name of the file in the application's main bundle
    @available(*, deprecated, message: "Use `BundleImageSource` instead")
    public init?(imageString: String, caption: String = "", captionBottomConstraint: CGFloat = 0, showCaptionOnlyInFullScreen: Bool = false) {
        if let image = UIImage(named: imageString) {
            self.image = image
            self.caption = caption
            self.captionBottomConstraint = captionBottomConstraint
            self.showCaptionOnlyInFullScreen = showCaptionOnlyInFullScreen
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?, String?, CGFloat, Bool) -> Void) {
        imageView.image = image
        callback(image, caption, captionBottomConstraint, showCaptionOnlyInFullScreen)
    }
}

/// Input Source to load an image from the main bundle
@objcMembers
open class BundleImageSource: NSObject, InputSource {
    var imageString: String
    var caption: String
    var captionBottomConstraint: CGFloat
    var showCaptionOnlyInFullScreen: Bool

    /// Initializes a new Image Source with an image name from the main bundle
    /// - parameter imageString: name of the file in the application's main bundle
    public init(imageString: String, caption: String = "", captionBottomConstraint: CGFloat = 0, showCaptionOnlyInFullScreen: Bool = false) {
        self.imageString = imageString
        self.caption = caption
        self.captionBottomConstraint = captionBottomConstraint
        self.showCaptionOnlyInFullScreen = showCaptionOnlyInFullScreen

        super.init()
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?, String?, CGFloat, Bool) -> Void) {
        let image = UIImage(named: imageString)
        imageView.image = image
        callback(image, caption, captionBottomConstraint, showCaptionOnlyInFullScreen)
    }
}

/// Input Source to load an image from a local file path
@objcMembers
open class FileImageSource: NSObject, InputSource {
    var path: String
    var caption: String
    var captionBottomConstraint: CGFloat
    var showCaptionOnlyInFullScreen: Bool

    /// Initializes a new Image Source with an image name from the main bundle
    /// - parameter imageString: name of the file in the application's main bundle
    public init(path: String, caption: String = "", captionBottomConstraint: CGFloat = 0, showCaptionOnlyInFullScreen: Bool = false) {
        self.path = path
        self.caption = caption
        self.captionBottomConstraint = captionBottomConstraint
        self.showCaptionOnlyInFullScreen = showCaptionOnlyInFullScreen

        super.init()
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?, String?, CGFloat, Bool) -> Void) {
        let image = UIImage(contentsOfFile: path)
        imageView.image = image
        callback(image, caption, captionBottomConstraint, showCaptionOnlyInFullScreen)
    }
}
