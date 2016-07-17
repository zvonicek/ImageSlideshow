//
//  SDWebImageSource.swift
//  ImageSlideshow
//
//  Created by Nik Kov on 06.07.16.
//
//

import SDWebImage

public class SDWebImageSource: NSObject, InputSource {
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
        imageView.sd_setImageWithURL(self.url, placeholderImage: self.placeholder)
    }
}