//
//  KingfisherSource.swift
//  ImageSlideshow
//
//  Created by feiin
//
//

import UIKit
#if SWIFT_PACKAGE
import ImageSlideshow
#endif
import Kingfisher

/// Input Source to image using Kingfisher
public class KingfisherSource: NSObject, InputSource {
    /// url to load
    public var url: URL

    /// placeholder used before image is loaded
    public var placeholder: UIImage?

    /// options for displaying, ie. [.transition(.fade(0.2))]
    public var options: KingfisherOptionsInfo?

    /// Initializes a new source with a URL
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    /// - parameter options: options for displaying
    public init(url: URL, placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = nil) {
        self.url = url
        self.placeholder = placeholder
        self.options = options
        super.init()
    }

    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    /// - parameter options: options for displaying
    public init?(urlString: String, placeholder: UIImage? = nil, options: KingfisherOptionsInfo? = nil) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            self.placeholder = placeholder
            self.options = options
            super.init()
        } else {
            return nil
        }
    }

    /// Load an image to an UIImageView
    ///
    /// - Parameters:
    ///   - imageView: UIImageView that receives the loaded image
    ///   - callback: Completion callback with an optional image
    @objc
    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.kf.setImage(with: self.url, placeholder: self.placeholder, options: self.options, progressBlock: nil) { result in
            switch result {
            case .success(let image):
                callback(image.image)
            case .failure:
                callback(self.placeholder)
            }
        }
    }

    /// Cancel an image download task
    ///
    /// - Parameter imageView: UIImage view with the download task that should be canceled
    public func cancelLoad(on imageView: UIImageView) {
        imageView.kf.cancelDownloadTask()
    }
}
