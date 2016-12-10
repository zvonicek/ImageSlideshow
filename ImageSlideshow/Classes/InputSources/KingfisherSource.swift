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

    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
        imageView.kf.setImage(with: self.url, placeholder: self.placeholder, options: nil, progressBlock: nil) { (image, _, _, _) in
            if let image = image {
                callback(image)
            }
        }
    }
}
