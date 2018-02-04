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

public protocol PageIndicatorView {
    var view: UIView { get }
    var height: CGFloat { get }
    var page: Int { get }
    var numberOfPages: Int { get set}

    func setPage(_ page: Int)
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
        return currentPage
    }

    public func setPage(_ page: Int) {
        currentPage = page
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

    public func setPage(_ page: Int) {
        self.page = page
    }

    private func updateLabel() {
        text = "\(page+1)/\(numberOfPages)"
    }
}
