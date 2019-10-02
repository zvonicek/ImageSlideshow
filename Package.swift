// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ImageSlideshow",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "ImageSlideshow/Core",
            targets: ["ImageSlideshowCore"]),
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
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "3.0.0"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "3.7.0"),
        .package(url: "https://github.com/parse-community/Parse-Swift.git", .upToNextMinor(from: "1.14.0")),
    ],
    targets: [
        .target(
            name: "ImageSlideshowCore",
            dependencies: ["ImageSlideshow"],
            path: "ImageSlideshow",
            sources: ["/Classes/Core/*", "/Assets/*"]),
        .target(
            name: "ImageSlideshowAlamofire",
            dependencies: ["ImageSlideshow", "AlamofireImage"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/AlamofireSource.swift"]),
        .target(
            name: "ImageSlideshowSDWebImage",
            dependencies: ["ImageSlideshow", "SDWebImage"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/SDWebImageSource.swift"]),
        .target(
            name: "ImageSlideshowKingfisher",
            dependencies: ["ImageSlideshow", "Kingfisher"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/KingfisherSource.swift"]),
        .target(
            name: "ImageSlideshowParse",
            dependencies: ["ImageSlideshow", "Parse"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/ParseSource.swift"])
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
