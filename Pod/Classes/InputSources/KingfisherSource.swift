//
//  KingfisherSource.swift
//  ImageSlideshow
//
//  Created by feiin
//
//

import Kingfisher

public class KingfisherSource: NSObject, InputSource {
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
        imageView.kf.setImage(with: self.url, placeholder: self.placeholder)
    }
}
