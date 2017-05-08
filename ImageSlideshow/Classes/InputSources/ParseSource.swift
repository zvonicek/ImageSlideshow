//
//  ParseImageSource.swift
//  ImageSlideshow
//
//  Created by Jaime Agudo Lopez on 14/01/2017.
//

import Parse

/// Input Source to image using Parse
public class ParseSource: NSObject, InputSource {
    var file: PFFile
    var placeholder: UIImage?

    /// Initializes a new source with URL and optionally a placeholder
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(file: PFFile, placeholder: UIImage? = nil) {
        self.file = file
        self.placeholder = placeholder
        super.init()
    }

    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        self.file.getDataInBackground {(data: Data?, error: Error?) in
            if let data = data, let image = UIImage(data: data) {
                imageView.image = image
                callback(image)
            } else {
                callback(nil)
            }
        }
    }
}
