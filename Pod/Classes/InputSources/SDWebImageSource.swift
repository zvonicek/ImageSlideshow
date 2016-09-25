//
//  SDWebImageSource.swift
//  ImageSlideshow
//
//  Created by Nik Kov on 06.07.16.
//
//

import SDWebImage

public class SDWebImageSource: NSObject, InputSource {
    var url: URL
    var placeholder: UIImage?
    
    public init(url: URL) {
        self.url = url
        super.init()
    }
    
    public init(url: URL, placeholder: UIImage) {
        self.url = url
        self.placeholder = placeholder
        super.init()
    }
    
    public init?(urlString: String) {
        if let validUrl = URL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            return nil
        }
    }

    @objc public func set(to imageView: UIImageView) {
        imageView.sd_setImage(with: self.url, placeholderImage: self.placeholder)
    }
}
