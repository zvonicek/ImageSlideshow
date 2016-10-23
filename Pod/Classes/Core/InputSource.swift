//
//  InputSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import UIKit

@objc public protocol InputSource {
    func load(to imageView: UIImageView, with callback: @escaping (_ image: UIImage) -> ())
}

open class ImageSource: NSObject, InputSource {
    var image: UIImage!
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public init?(imageString: String) {
        if let image = UIImage(named: imageString) {
            self.image = image
            super.init()
        } else {
            return nil
        }
    }

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
        imageView.image = image
        callback(image)
    }
}
