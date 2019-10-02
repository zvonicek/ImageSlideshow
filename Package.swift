// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ImageSlideshow",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "ImageSlideshow",
            targets: ["ImageSlideshow"]),
        .library(
            name: "ImageSlideshow/Alamofire",
            targets: ["ImageSlideshowAlamofire"]),
        .library(
            name: "ImageSlideshow/SDWebImage",
            targets: ["ImageSlideshowSDWebImage"]),
        .library(
            name: "ImageSlideshow/Kingfisher",
            targets: ["ImageSlideshowKingfisher"]),
        .library(
            name: "ImageSlideshow/Parse",
            targets: ["ImageSlideshowParse"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "5.8.0"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", .branch("master")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0"),
        .package(url: "https://github.com/parse-community/Parse-Swift.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "ImageSlideshow",
            path: "ImageSlideshow",
            sources: [
                "Classes/Core/ActivityIndicator.swift",
                "Classes/Core/FullScreenSlideshowViewController.swift",
                "Classes/Core/ImageSlideshow.swift",
                "Classes/Core/ImageSlideshowItem.swift",
                "Classes/Core/InputSource.swift",
                "Classes/Core/PageIndicator.swift",
                "Classes/Core/PageIndicatorPosition.swift",
                "Classes/Core/SwiftSupport.swift",
                "Classes/Core/UIImage+AspectFit.swift",
                "Classes/Core/UIImageView+Tools.swift",
                "Classes/Core/ZoomAnimatedTransitioning.swift",
                "Assets/ic_cross_white@2x.png",
                "Assets/ic_cross_white@3x.png",
            ]),
        .target(
            name: "ImageSlideshowAlamofire",
            dependencies: ["ImageSlideshow", "AlamofireImage"],
            path: "ImageSlideshow/Classes/InputSources",
            sources: ["AlamofireSource.swift"]),
        .target(
            name: "ImageSlideshowSDWebImage",
            dependencies: ["ImageSlideshow", "SDWebImage"],
            path: "ImageSlideshow/Classes/InputSources",
            sources: ["SDWebImageSource.swift"]),
        .target(
            name: "ImageSlideshowKingfisher",
            dependencies: ["ImageSlideshow", "Kingfisher"],
            path: "ImageSlideshow/Classes/InputSources",
            sources: ["KingfisherSource.swift"]),
        .target(
            name: "ImageSlideshowParse",
            dependencies: ["ImageSlideshow", "ParseSwift"],
            path: "ImageSlideshow/Classes/InputSources",
            sources: ["ParseSource.swift"])
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
