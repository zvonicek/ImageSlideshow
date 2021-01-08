//
//  ZoomableMediaSlideshowSlide.swift
//  MediaSlideshow
//
//  Created by Peter Meyers on 1/7/21.
//

import UIKit

/// A slideshow item that can be further zoomed in after transitioning to fullscreen.
public protocol ZoomableMediaSlideshowSlide: MediaSlideshowSlide {
    var zoomInInitially: Bool { get }

    var maximumZoomScale: CGFloat { get }

    func isZoomed() -> Bool

    func zoomOut()
}

extension ZoomableMediaSlideshowSlide where Self: UIScrollView {
    public func isZoomed() -> Bool {
        return self.zoomScale != self.minimumZoomScale
    }

    public func zoomOut() {
        self.setZoomScale(minimumZoomScale, animated: false)
    }
}
