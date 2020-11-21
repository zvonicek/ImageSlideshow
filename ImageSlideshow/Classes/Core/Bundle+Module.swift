//
//  Bundle+Module.swift
//  ImageSlideshow
//
//  Created by woxtu on 20/11/21.
//

import Foundation

#if !SWIFT_PACKAGE
extension Bundle {
    static var module: Bundle = {
        return Bundle(for: ImageSlideshow.self)
    }()
}
#endif
