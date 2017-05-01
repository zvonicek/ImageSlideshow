//
//  AFURLSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import AFNetworking

/// Input Source to image using AFNetworking
public class AFURLSource: NSObject, InputSource {
    /// url to load
    public var url: URL

    /// placeholder used before image is loaded
    public var placeholder: UIImage?

    /// Initializes a new source with URL and placeholder
    /// - parameter url: a url to load
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
            self.placeholder = placeholder
            self.url = validUrl
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.setImageWith(URLRequest(url: url), placeholderImage: self.placeholder, success: { (_, _, image: UIImage) in
            callback(image)
        }, failure: { _, _, _ in
            callback(nil)
        })
    }
}
