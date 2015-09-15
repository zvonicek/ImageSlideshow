//
//  AFURLSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 30.07.15.
//  Copyright (c) 2015 Petr Zvonicek. All rights reserved.
//

import AFNetworking

public class AFURLSource: NSObject, InputSource {
    let url: NSURL!
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public init?(urlString: String) {
        if let validUrl = NSURL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            // working around Swift 1.2 failure initializer bug
            self.url = NSURL(string: "")!
            super.init()
            return nil
        }
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: nil, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
            imageView.image = image
            }, failure: nil)
    }
}