//
//  InputSource.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import Foundation

@objc public protocol InputSource {
    func setToImageView(imageView: UIImageView);
}

public class ImageSource: NSObject, InputSource {
    var image: UIImage!
    
    public init(image: UIImage) {
        self.image = image
    }
    
    public init?(imageString: String) {
        if let imageObj = UIImage(named: imageString) {
            self.image = imageObj
            super.init()
        } else {
            // this may be simplified in Swift 2.2, which fixes the failable initializer compiler issues
            super.init()
            return nil
        }
    }
    
    @objc public func setToImageView(imageView: UIImageView) {
        imageView.image = self.image
    }
}
