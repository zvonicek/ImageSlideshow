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
    var url: NSURL!
    
    public init(url: NSURL) {
        self.url = url
        super.init()
    }

    public init?(urlString: String) {
        if let validUrl = NSURL(string: urlString) {
            self.url = validUrl
            super.init()
        } else {
            super.init()
            return nil
        }
    }
    
    public func setToImageView(imageView: UIImageView) {
        Alamofire.request(.GET, self.url)
            .responseImage { response in
                if let image = response.result.value {
                    imageView.image = image
                }
        }
    }
    
}
