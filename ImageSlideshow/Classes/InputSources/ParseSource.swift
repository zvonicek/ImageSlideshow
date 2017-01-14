//
//  ParseImageSource.swift
//  ImageSlideshow
//
//  Created by Jaime Agudo Lopez on 14/01/2017.
//

import ImageSlideshow
import Parse

/// Input Source to image using Parse
public class ParseSource: NSObject, InputSource {
    var file: PFFile
    var placeholder: UIImage?

    //@abstract Initializes a new source with URL and optionally a placeholder
    /// - parameter url: a url to be loaded
    /// - parameter placeholder: a placeholder used before image is loaded
    public init(file: PFFile, placeholder: UIImage? = nil) {
        self.file = file
        self.placeholder = placeholder
        super.init()
    }


    @objc public func load(to imageView: UIImageView, with callback: @escaping (UIImage) -> ()) {
      // maybe  callback(self.placeholder!) while it loads
      self.file.getDataInBackground {(imageData: Data?, error:Error?) in
          if let e = error  {
              print(e)
          }
          if let data = imageData {
              if let img=UIImage(data:data){
                callback(img!)
              }
          }
        }
    }
}
