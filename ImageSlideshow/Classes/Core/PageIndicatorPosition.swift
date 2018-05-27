//
//  PageIndicator.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 04.02.18.
//

import UIKit

public struct PageIndicatorPosition {
    public enum Horizontal {
        case left(padding: CGFloat), center, right(padding: CGFloat)
    }

    public enum Vertical {
        case top, bottom, under, customTop(padding: CGFloat), customBottom(padding: CGFloat), customUnder(padding: CGFloat)
    }

    var horizontal: Horizontal
    var vertical: Vertical

    public init(horizontal: Horizontal = .center, vertical: Vertical = .bottom) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

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
