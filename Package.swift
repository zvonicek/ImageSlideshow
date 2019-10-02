// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ImageSlideshow",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "Core",
            targets: ["ImageSlideshow"]),
        .library(
            name: "Alamofire",
            targets: ["Alamofire"]),
        .library(
            name: "SDWebImage",
            targets: ["SDWebImage"]),
        .library(
            name: "Kingfisher",
            targets: ["Kingfisher"]),
        .library(
            name: "Parse",
            targets: ["Parse"])
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "3.0"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", from: "3.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "3.7"),
        .package(url: "https://github.com/parse-community/Parse-Swift.git", from: "1.14"),
    ],
    targets: [
        .target(
            name: "ImageSlideshow",
            dependencies: ["ImageSlideshow"],
            path: "ImageSlideshow",
            sources: ["/Classes/Core/*", "/Assets/*"]),
        .target(
            name: "Alamofire",
            dependencies: ["ImageSlideshow", "AlamofireImage"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/AlamofireSource.swift"]),
        .target(
            name: "SDWebImage",
            dependencies: ["ImageSlideshow", "SDWebImage"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/SDWebImageSource.swift"]),
        .target(
            name: "Kingfisher",
            dependencies: ["ImageSlideshow", "Kingfisher"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/KingfisherSource.swift"]),
        .target(
            name: "Parse",
            dependencies: ["ImageSlideshow", "Parse"],
            path: "ImageSlideshow",
            sources: ["/Classes/InputSources/ParseSource.swift"])
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
