//
//  KingfisherSource.swift
//  ImageSlideshow
//
//  Created by feiin
//
//

import Kingfisher

/// Input Source to image using Kingfisher
public class KingfisherSource: NSObject, InputSource {
    /// url to load
    public var url: URL

    /// placeholder used before image is loaded
    public var placeholder: UIImage?

    /// Initializes a new source with a URL
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded    
    public init(url: URL, placeholder: UIImage? = nil) {
        self.url = url
        self.placeholder = placeholder
        super.init()
    }

    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to load
    /// - parameter placeholder: a placeholder used before image is loaded
    public init?(urlString: String, placeholder: UIImage? = nil) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            self.placeholder = placeholder
            super.init()
        } else {
            return nil
        }
    }

    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.kf.setImage(with: self.url, placeholder: self.placeholder, options: nil, progressBlock: nil) { (image, _, _, _) in
            callback(image)
        }
    }
}
