//
//  AFURLSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import AFNetworking

/// Input Source to image using AFNetworking
public class AFURLSource: NSObject, InputSource {
    var url: URL
    var placeholder: UIImage?

    /// Initializes a new source with a URL
    /// - parameter url: a url to be loaded
    public init(url: URL) {
        self.url = url
        super.init()
    }

    /// Initializes a new source with URL and placeholder
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(url: URL, placeholder: UIImage) {
        self.url = url
        self.placeholder = placeholder
        super.init()
    }

    /// Initializes a new source with a URL string
    /// - parameter urlString: a string url to be loaded
    public init?(urlString: String) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> Void) {
        imageView.setImageWith(URLRequest(url: url), placeholderImage: self.placeholder, success: { (_, _, image: UIImage) in
            imageView.image = image
            callback(image)
            }, failure: nil)
    }
}
