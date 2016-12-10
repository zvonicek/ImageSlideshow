//
//  AlamofireSource.swift
//  Pods
//
//  Created by Petr Zvoníček on 14.01.16.
//
//

import Alamofire
import AlamofireImage

public class AlamofireSource: NSObject, InputSource {
    var url: URL
    
    public init(url: URL) {
        self.url = url
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

    public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
        imageView.af_setImage(withURL: self.url, placeholderImage: nil, filter: nil, progress: nil) { (response) in
            imageView.image = response.result.value
            if let value = response.result.value {
                callback(value)
            }
        }
    }
    
}
