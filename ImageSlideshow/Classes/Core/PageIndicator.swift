//
//  PageIndicator.swift
//  AFNetworking
//
//  Created by Petr Zvoníček on 04.02.18.
//

import UIKit

public enum PageIndicatorPosition {
    case top
    case bottom
    case under
    case customBottom(padding: CGFloat)

    var bottomPadding: CGFloat {
        switch self {
        case .bottom, .top:
            return 0.0
        case .under:
            return 30.0
        case .customBottom(let padding):
            return padding
        }
    }
}

public protocol PageIndicatorView: class {
    var view: UIView { get }
    var height: CGFloat { get }
    var page: Int { get set }
    var numberOfPages: Int { get set}
}

extension PageIndicatorView {
    public var height: CGFloat {
        return view.intrinsicContentSize.height
    }
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
}
