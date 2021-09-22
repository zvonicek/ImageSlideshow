// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ImageSlideshow",
    platforms: [
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
            targets: ["ImageSlideshowKingfisher"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "5.8.0"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "4.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "ImageSlideshow",
            path: "ImageSlideshow",
            sources: [
                "Classes/Core/ActivityIndicator.swift",
                "Classes/Core/Bundle+Module.swift",
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
            ],
            resources: [
                .copy("Assets/ic_cross_white@2x.png"),
                .copy("Assets/ic_cross_white@3x.png"),
            ]),
        .target(
            name: "ImageSlideshowAlamofire",
            dependencies: ["ImageSlideshow", "AlamofireImage"],
            path: "ImageSlideshow/Classes/InputSources",
            exclude: ["AFURLSource.swift",
                      "KingfisherSource.swift",
                      "ParseSource.swift",
                      "SDWebImageSource.swift"],
            sources: ["AlamofireSource.swift",
                      "AlamofireLegacySource.swift"]),
        .target(
            name: "ImageSlideshowSDWebImage",
            dependencies: ["ImageSlideshow", "SDWebImage"],
            path: "ImageSlideshow/Classes/InputSources",
            exclude: ["AFURLSource.swift",
                      "AlamofireSource.swift",
                      "AlamofireLegacySource.swift",
                      "KingfisherSource.swift",
                      "ParseSource.swift"],            
            sources: ["SDWebImageSource.swift"]),
        .target(
            name: "ImageSlideshowKingfisher",
            dependencies: ["ImageSlideshow", "Kingfisher"],
            path: "ImageSlideshow/Classes/InputSources",
            exclude: ["AFURLSource.swift",
                      "AlamofireSource.swift",
                      "AlamofireLegacySource.swift",
                      "SDWebImageSource.swift",
                      "ParseSource.swift"],              
            sources: ["KingfisherSource.swift"])
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
