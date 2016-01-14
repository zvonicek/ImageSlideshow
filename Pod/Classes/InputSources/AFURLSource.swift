//
//  AFURLSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//

import AFNetworking

public class AFURLSource: NSObject, InputSource {
    var url: NSURL!
    var placeholder: UIImage?
    
    public init(url: NSURL) {
        self.url = url
        super.init()
    }
    
    public init(url: NSURL, placeholder: UIImage) {
        self.url = url
        self.placeholder = placeholder
        super.init()
    }
    
    public init?(urlString: String) {
        if let validUrl = NSURL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            super.init()
            return nil
        }
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: self.placeholder, success: { (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
            imageView.image = image
            }, failure: nil)
    }

}