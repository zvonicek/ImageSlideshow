//
//  KingfisherSource.swift
//  ImageSlideshow
//
//  Created by feiin
//
//

import Kingfisher

public class KingfisherSource: NSObject, InputSource {
    var url: NSURL
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
            return nil
        }
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.kf_setImageWithURL(self.url, placeholderImage: self.placeholder)
    }
}
