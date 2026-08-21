// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ImageSlideshow",
    platforms: [
        .iOS(.v12),
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
    traits: [
        .trait(name: "Alamofire"),
        .trait(name: "SDWebImage"),
        .trait(name: "Kingfisher")
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
            exclude: [
                "Classes/InputSources/AFURLSource.swift",
                "Classes/InputSources/AlamofireLegacySource.swift",
                "Classes/InputSources/AlamofireSource.swift",
                "Classes/InputSources/KingfisherSource.swift",
                "Classes/InputSources/ParseSource.swift",
                "Classes/InputSources/SDWebImageSource.swift"
            ],
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
            dependencies: [
                "ImageSlideshow",
                .product(
                    name: "AlamofireImage",
                    package: "AlamofireImage",
                    condition: .when(traits: ["Alamofire"])
                )
            ],
            path: "ImageSlideshow/Classes/InputSources",
            exclude: [
                "AFURLSource.swift",
                "AlamofireLegacySource.swift",
                "KingfisherSource.swift",
                "ParseSource.swift",
                "SDWebImageSource.swift"
            ],
            sources: ["AlamofireSource.swift"]),
        .target(
            name: "ImageSlideshowSDWebImage",
            dependencies: [
                "ImageSlideshow",
                .product(
                    name: "SDWebImage",
                    package: "SDWebImage",
                    condition: .when(traits: ["SDWebImage"])
                )
            ],
            path: "ImageSlideshow/Classes/InputSources",
            exclude: [
                "AFURLSource.swift",
                "AlamofireLegacySource.swift",
                "AlamofireSource.swift",
                "KingfisherSource.swift",
                "ParseSource.swift"
            ],
            sources: ["SDWebImageSource.swift"]),
        .target(
            name: "ImageSlideshowKingfisher",
            dependencies: [
                "ImageSlideshow",
                .product(
                    name: "Kingfisher",
                    package: "Kingfisher",
                    condition: .when(traits: ["Kingfisher"])
                )
            ],
            path: "ImageSlideshow/Classes/InputSources",
            exclude: [
                "AFURLSource.swift",
                "AlamofireLegacySource.swift",
                "AlamofireSource.swift",
                "ParseSource.swift",
                "SDWebImageSource.swift"
            ],
            sources: ["KingfisherSource.swift"])
    ],
    swiftLanguageModes: [.v5]
)
