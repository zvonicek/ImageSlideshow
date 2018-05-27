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

    func indicatorFrame(for parentFrame: CGRect, indicatorSize: CGSize, bottomInset: CGFloat) -> CGRect {
        var xSize: CGFloat = 0
        var ySize: CGFloat = 0

        switch horizontal {
        case .center:
            xSize = parentFrame.size.width / 2 - indicatorSize.width / 2
        case .left(let padding):
            xSize = padding
        case .right(let padding):
            xSize = parentFrame.size.width - indicatorSize.width - padding
        }

        switch vertical {
        case .bottom, .under, .customUnder:
            ySize = parentFrame.size.height - indicatorSize.height
        case .customBottom(let padding):
            ySize = parentFrame.size.height - indicatorSize.height - padding
        case .top:
            ySize = 0
        case .customTop(let padding):
            ySize = padding
        }
        ySize -= bottomInset

        return CGRect(x: xSize, y: ySize, width: indicatorSize.width, height: indicatorSize.height)
    }
}

public protocol PageIndicatorView: class {
    var view: UIView { get }
    var page: Int { get set }
    var numberOfPages: Int { get set}
}

extension UIPageControl: PageIndicatorView {
    public var view: UIView {
        return self
    }

    public var page: Int {
        get {
            return currentPage
        }
        set {
            currentPage = newValue
        }
    }

    open override func sizeToFit() {
        var frame = self.frame
        frame.size = size(forNumberOfPages: numberOfPages)
        frame.size.height = 30
        self.frame = frame
    }
}

public class LabelPageIndicator: UILabel, PageIndicatorView {
    public var view: UIView {
        return self
    }

    public var numberOfPages: Int = 0 {
        didSet {
            updateLabel()
        }
    }

    public var page: Int = 0 {
        didSet {
            updateLabel()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        self.textAlignment = .center
    }

    private func updateLabel() {
        text = "\(page+1)/\(numberOfPages)"
    }

    public override func sizeToFit() {
        let maximumString = String(repeating: "8", count: numberOfPages) as NSString
        self.frame.size = maximumString.size(withAttributes: [.font: self.font])
    }
}
