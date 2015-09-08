//
//  AFURLSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//  Copyright (c) 2015 Petr Zvonicek. All rights reserved.
//

import ImageSlideshow
import AFNetworking

public class AFURLSource: InputSource {
    let url: NSURL!
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public init?(url: String) {
        if let validUrl = NSURL(string: url) {
            self.url = validUrl
        } else {
            // working around Swift 1.2 failure initializer bug
            self.url = NSURL(string: "")!
            return nil
        }
    }
    
    public func setToImageView(imageView: UIImageView) {
        imageView.setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: nil, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
            imageView.image = image
            }, failure: nil)
    }
}