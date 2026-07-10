import UIKit
import XCTest
@testable import ImageSlideshow

/// Input source stub that synchronously reports the given image (nil = failure)
private class StubSource: NSObject, @preconcurrency InputSource {
    let image: UIImage?

    init(image: UIImage?) {
        self.image = image
        super.init()
    }

    @MainActor func load(to imageView: UIImageView, with callback: @escaping (UIImage?) -> Void) {
        imageView.image = image
        callback(image)
    }
}

private func solidImage() -> UIImage {
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    defer { UIGraphicsEndImageContext() }
    return UIGraphicsGetImageFromCurrentImageContext()!
}

@MainActor
class PagingTests: XCTestCase {

    private let width: CGFloat = 300

    private func makeSlideshow(circular: Bool, count: Int) -> ImageSlideshow {
        let slideshow = ImageSlideshow(frame: CGRect(x: 0, y: 0, width: width, height: 200))
        slideshow.circular = circular
        slideshow.setImageInputs((0..<count).map { _ in StubSource(image: solidImage()) })
        return slideshow
    }

    func testCircularAddsDummyEdgePages() {
        let slideshow = makeSlideshow(circular: true, count: 3)

        // 3 images + a copy of the last at index 0 and of the first at the end
        XCTAssertEqual(slideshow.scrollView.contentSize.width, width * 5)
        // starts on scroll view page 1, which is the first real image
        XCTAssertEqual(slideshow.scrollViewPage, 1)
        XCTAssertEqual(slideshow.currentPage, 0)
    }

    func testNonCircularHasNoDummyPages() {
        let slideshow = makeSlideshow(circular: false, count: 3)

        XCTAssertEqual(slideshow.scrollView.contentSize.width, width * 3)
        XCTAssertEqual(slideshow.scrollViewPage, 0)
        XCTAssertEqual(slideshow.currentPage, 0)
    }

    func testSingleImageDoesNotUseCircularLayout() {
        let slideshow = makeSlideshow(circular: true, count: 1)

        XCTAssertEqual(slideshow.scrollView.contentSize.width, width)
        XCTAssertEqual(slideshow.scrollViewPage, 0)
    }

    func testSetCurrentPageOffsetsForCircularDummy() {
        let slideshow = makeSlideshow(circular: true, count: 3)

        slideshow.setCurrentPage(2, animated: false)

        XCTAssertEqual(slideshow.currentPage, 2)
        XCTAssertEqual(slideshow.scrollViewPage, 3)
    }

    func testDummyEdgePagesMapToRealPages() {
        let slideshow = makeSlideshow(circular: true, count: 3)

        // scroll view page 0 holds a copy of the last image
        slideshow.setScrollViewPage(0, animated: false)
        XCTAssertEqual(slideshow.currentPage, 2)

        // the last scroll view page holds a copy of the first image
        slideshow.setScrollViewPage(4, animated: false)
        XCTAssertEqual(slideshow.currentPage, 0)
    }

    func testNextPageWrapsWhenCircular() {
        let slideshow = makeSlideshow(circular: true, count: 3)
        slideshow.setCurrentPage(2, animated: false)

        slideshow.nextPage(animated: false)

        XCTAssertEqual(slideshow.currentPage, 0)
    }

    func testNextPageStopsAtLastPageWhenNotCircular() {
        let slideshow = makeSlideshow(circular: false, count: 3)
        slideshow.setCurrentPage(2, animated: false)

        slideshow.nextPage(animated: false)

        XCTAssertEqual(slideshow.currentPage, 2)
    }

    func testPreviousPageStopsAtFirstPageWhenNotCircular() {
        let slideshow = makeSlideshow(circular: false, count: 3)

        slideshow.previousPage(animated: false)

        XCTAssertEqual(slideshow.currentPage, 0)
    }

    func testPageChangeCallbackReported() {
        let slideshow = makeSlideshow(circular: false, count: 3)
        var reportedPage: Int?
        slideshow.currentPageChanged = { reportedPage = $0 }

        slideshow.setCurrentPage(1, animated: false)

        XCTAssertEqual(reportedPage, 1)
    }
}

@MainActor
class PageIndicatorPositionTests: XCTestCase {

    private let indicatorSize = CGSize(width: 40, height: 20)
    private let parentFrame = CGRect(x: 0, y: 0, width: 300, height: 200)

    func testUnderPadding() {
        XCTAssertEqual(PageIndicatorPosition(vertical: .under).underPadding(for: indicatorSize), 20)
        XCTAssertEqual(PageIndicatorPosition(vertical: .customUnder(padding: 10)).underPadding(for: indicatorSize), 30)
        XCTAssertEqual(PageIndicatorPosition(vertical: .bottom).underPadding(for: indicatorSize), 0)
        XCTAssertEqual(PageIndicatorPosition(vertical: .top).underPadding(for: indicatorSize), 0)
    }

    func testIndicatorFrameCenterBottom() {
        let position = PageIndicatorPosition(horizontal: .center, vertical: .bottom)

        let frame = position.indicatorFrame(for: parentFrame, indicatorSize: indicatorSize, edgeInsets: .zero)

        XCTAssertEqual(frame, CGRect(x: 130, y: 180, width: 40, height: 20))
    }

    func testIndicatorFrameRespectsEdgeInsets() {
        let position = PageIndicatorPosition(horizontal: .right(padding: 5), vertical: .top)
        let insets = UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 10)

        let frame = position.indicatorFrame(for: parentFrame, indicatorSize: indicatorSize, edgeInsets: insets)

        XCTAssertEqual(frame.origin.x, 300 - 40 - 5 - 10)
        XCTAssertEqual(frame.origin.y, 44)
    }

    func testIndicatorFrameLeftCustomTop() {
        let position = PageIndicatorPosition(horizontal: .left(padding: 8), vertical: .customTop(padding: 12))

        let frame = position.indicatorFrame(for: parentFrame, indicatorSize: indicatorSize, edgeInsets: .zero)

        XCTAssertEqual(frame.origin, CGPoint(x: 8, y: 12))
    }
}

@MainActor
class InputSourceContractTests: XCTestCase {

    func testImageSourceLoadsSynchronously() {
        let image = solidImage()
        let imageView = UIImageView()
        var callbackImage: UIImage?

        ImageSource(image: image).load(to: imageView) { callbackImage = $0 }

        XCTAssertTrue(imageView.image === image)
        XCTAssertTrue(callbackImage === image)
    }

    func testFailedLoadEnablesRetryAndDisablesZoom() {
        let item = ImageSlideshowItem(image: StubSource(image: nil), zoomEnabled: true)

        item.loadImage()

        XCTAssertNil(item.imageView.image)
        // zoom double-tap is swapped for the retry single-tap on failure
        XCTAssertEqual(item.gestureRecognizer?.isEnabled, false)
    }

    func testSuccessfulLoadKeepsZoomEnabled() {
        let item = ImageSlideshowItem(image: StubSource(image: solidImage()), zoomEnabled: true)

        item.loadImage()

        XCTAssertNotNil(item.imageView.image)
        XCTAssertEqual(item.gestureRecognizer?.isEnabled, true)
    }
}
