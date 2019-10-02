//
//  ParseImageSource.swift
//  ImageSlideshow
//
//  Created by Jaime Agudo Lopez on 14/01/2017.
//

import Foundation
import UIKit
import ImageSlideshow
import ParseSwift

/// Input Source to image using Parse
public class ParseSource: NSObject, InputSource {
    var file: File
    var placeholder: UIImage?

    /// Initializes a new source with URL and optionally a placeholder
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(file: File, placeholder: UIImage? = nil) {
        self.file = file
        self.placeholder = placeholder
        super.init()
    }

    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.image = self.placeholder

        self.file.fetch { (file, error) in
            if let data = file?.data, let image = UIImage(data: data) {
                imageView.image = image
                callback(image)
            } else {
                callback(nil)
            }
        }
    }
}
