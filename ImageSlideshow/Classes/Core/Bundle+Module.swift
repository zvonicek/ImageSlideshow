//
//  Bundle+Module.swift
//  ImageSlideshow
//
//  Created by woxtu on 20/11/21.
//

import Foundation

#if !SWIFT_PACKAGE
extension Bundle {
    static let module = Bundle(for: ImageSlideshow.self)
}
#endif
