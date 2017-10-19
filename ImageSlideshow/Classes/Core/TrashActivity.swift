//
//  TrashActivity.swift
//  ImageSlideshow
//
//  Created by Christopher G Prince on 10/18/17.
//  Copyright © 2017 Spastic Muffin, LLC. All rights reserved.
//

import Foundation
import UIKit

class TrashActivity : UIActivity {
    var image: ImageSource!
    weak var parentVC: UIViewController!
    var removeImage:((ImageSource)->())!
    
    init(withParentVC parentVC: UIViewController, removeImage:@escaping (ImageSource)->()) {
        self.parentVC = parentVC
        self.removeImage = removeImage
    }
    
    // default returns nil. subclass may override to return custom activity type that is reported to completion handler
    override var activityType: UIActivityType? {
        return UIActivityType(rawValue: "\(type(of: self))")
    }

    // default returns nil. subclass must override and must return non-nil value
    override var activityTitle: String? {
        return "Delete\nImage"
    }
    
    override var activityImage: UIImage? {
        let bundle = Bundle(for: type(of: self))
        return UIImage(named: "Trash", in: bundle, compatibleWith: nil)!
    }
    
    // The array will contain ImageSource's and UIImage's-- filter out only the ImageSource's
    // override this to return availability of activity based on items. default returns NO
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        let imageSource = activityItems.filter({$0 is ImageSource})
        guard imageSource.count == 1, imageSource is [ImageSource] else {
            print("No Image's given!")
            return false
        }

        image = imageSource[0] as! ImageSource

        return true
    }
    
    override func perform() {
        super.perform()
        
        let alert = UIAlertController(title: "Delete image?", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = parentVC.view
    
        alert.addAction(UIAlertAction(title: "OK", style: .destructive) { alert in
            self.removeImage(self.image)
            self.activityDidFinish(true)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { alert in
            self.activityDidFinish(false)
        })

        parentVC.present(alert, animated: true, completion: nil)
    }
}
