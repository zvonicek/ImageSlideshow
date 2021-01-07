// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "MediaSlideshow",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "MediaSlideshow",
            targets: ["MediaSlideshow"]),
        .library(
            name: "MediaSlideshow/Alamofire",
            targets: ["MediaSlideshowAlamofire"]),
        .library(
            name: "MediaSlideshow/SDWebImage",
            targets: ["MediaSlideshowSDWebImage"]),
        .library(
            name: "MediaSlideshow/Kingfisher",
            targets: ["MediaSlideshowKingfisher"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "5.8.0"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "4.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "MediaSlideshow",
            path: "MediaSlideshow",
            sources: [
                "Classes/Core/ActivityIndicator.swift",
                "Classes/Core/Bundle+Module.swift",
                "Classes/Core/FullScreenSlideshowViewController.swift",
                "Classes/Core/MediaSlideshow.swift",
                "Classes/Core/MediaSlideshowImageSlide.swift",
                "Classes/Core/ImageSource.swift",
                "Classes/Core/PageIndicator.swift",
                "Classes/Core/PageIndicatorPosition.swift",
                "Classes/Core/SwiftSupport.swift",
                "Classes/Core/UIImage+AspectFit.swift",
                "Classes/Core/UIImageView+Tools.swift",
                "Classes/Core/ZoomAnimatedTransitioning.swift",
            ],
            resources: [
                .copy("Assets/ic_cross_white@2x.png"),
                .copy("Assets/ic_cross_white@3x.png"),
            ]),
        .target(
            name: "MediaSlideshowAlamofire",
            dependencies: ["MediaSlideshow", "AlamofireImage"],
            path: "MediaSlideshow/Classes/InputSources",
            sources: ["AlamofireSource.swift"]),
        .target(
            name: "MediaSlideshowSDWebImage",
            dependencies: ["MediaSlideshow", "SDWebImage"],
            path: "MediaSlideshow/Classes/InputSources",
            sources: ["SDWebImageSource.swift"]),
        .target(
            name: "MediaSlideshowKingfisher",
            dependencies: ["MediaSlideshow", "Kingfisher"],
            path: "MediaSlideshow/Classes/InputSources",
            sources: ["KingfisherSource.swift"])
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
