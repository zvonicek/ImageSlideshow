//
//  PageIndicator.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 04.02.18.
//

import UIKit

/// Describes the configuration of the page indicator position
public struct PageIndicatorPosition {
    public enum Horizontal {
        case left(padding: CGFloat), center, right(padding: CGFloat)
    }

    public enum Vertical {
        case top, bottom, under, customTop(padding: CGFloat), customBottom(padding: CGFloat), customUnder(padding: CGFloat)
    }

    /// Horizontal position of the page indicator
    var horizontal: Horizontal

    /// Vertical position of the page indicator
    var vertical: Vertical

    /// Creates a new PageIndicatorPosition struct
    ///
    /// - Parameters:
    ///   - horizontal: horizontal position of the page indicator
    ///   - vertical: vertical position of the page indicator
    public init(horizontal: Horizontal = .center, vertical: Vertical = .bottom) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    /// Computes the additional padding needed for the page indicator under the ImageSlideshow
    ///
    /// - Parameter indicatorSize: size of the page indicator
    /// - Returns: padding needed under the ImageSlideshow
    func underPadding(for indicatorSize: CGSize) -> CGFloat {
        switch vertical {
        case .under:
            return indicatorSize.height
        case .customUnder(let padding):
            return indicatorSize.height + padding
        default:
            return 0
        }
    }

    /// Computes the page indicator frame
    ///
    /// - Parameters:
    ///   - parentFrame: frame of the parent view – ImageSlideshow
    ///   - indicatorSize: size of the page indicator
    ///   - edgeInsets: edge insets of the parent view – ImageSlideshow (used for SafeAreaInsets adjustment)
    /// - Returns: frame of the indicator by computing the origin and using `indicatorSize` as size
    func indicatorFrame(for parentFrame: CGRect, indicatorSize: CGSize, edgeInsets: UIEdgeInsets) -> CGRect {
        var xSize: CGFloat = 0
        var ySize: CGFloat = 0

        switch horizontal {
        case .center:
            xSize = parentFrame.size.width / 2 - indicatorSize.width / 2
        case .left(let padding):
            xSize = padding + edgeInsets.left
        case .right(let padding):
            xSize = parentFrame.size.width - indicatorSize.width - padding - edgeInsets.right
        }

        switch vertical {
        case .bottom, .under, .customUnder:
            ySize = parentFrame.size.height - indicatorSize.height - edgeInsets.bottom
        case .customBottom(let padding):
            ySize = parentFrame.size.height - indicatorSize.height - padding - edgeInsets.bottom
        case .top:
            ySize = edgeInsets.top
        case .customTop(let padding):
            ySize = padding + edgeInsets.top
        }

        return CGRect(x: xSize, y: ySize, width: indicatorSize.width, height: indicatorSize.height)
    }
}
