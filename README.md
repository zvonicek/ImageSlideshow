# 🖼 ImageSlideshow

**Swift image slideshow with circular scrolling, timer and full screen viewer**

[![Build Status](https://www.bitrise.io/app/9aaf3e552f3a575c.svg?token=AjiVckTN9ItQtJs873mYMw&branch=master)](https://www.bitrise.io/app/9aaf3e552f3a575c)
[![Version](https://img.shields.io/cocoapods/v/ImageSlideshow.svg?style=flat)](http://cocoapods.org/pods/ImageSlideshow)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ImageSlideshow.svg?style=flat)](http://cocoapods.org/pods/ImageSlideshow)
[![Platform](https://img.shields.io/cocoapods/p/ImageSlideshow.svg?style=flat)](http://cocoapods.org/pods/ImageSlideshow)

![](http://cl.ly/image/2v193I0G0h0Z/ImageSlideshow2.gif)

## 📱 Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## 🔧 Installation

### CocoaPods
ImageSlideshow is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImageSlideshow', '~> 1.3'
```

### Carthage
To integrate ImageSlideshow into your Xcode project using Carthage, specify it in your Cartfile:

```ruby
github "zvonicek/ImageSlideshow" "1.3"
```

Carthage does not include InputSources for external providers (due to dependency on those providers) so you need to grab the one you need from `ImageSlideshow/Classes/InputSources` manually.

### Manually
One possibility is to download a builded framework (ImageSlideshow.framework.zip) from [releases page](https://github.com/zvonicek/ImageSlideshow/releases/) and link it with your project (under`Linked Frameworks and Libraries` in your target). This is, however, currently problematic because of rapid Swift development -- the framework is builded for a single Swift version and may not work on previous/future versions.

Alternatively can also grab the whole `ImageSlideshow` directory and copy it to your project. Be sure to remove those external Input Sources you don't need.

**Note on Swift 2.3 and Swift 3 support**

Version 1.0 supports Swift 3. For Swift 2.2 and Swift 2.3 compatible code use version 0.6 or branch *swift-2.3*.


## 🔨 How to use

Add ImageSlideshow view to your view hiearchy either in Interface Builder or in code.

### Loading images

Set images by using ```setImageInputs``` method on ```ImageSlideshow``` instance with an array of *InputSource*s. By default you can use ```ImageSource``` which takes ```UIImage``` or few other *InputSource*s for most popular networking libraries. You can also create your own input source by implementing ```InputSource``` protocol.

| Library                                                       | InputSource name | Pod                               |
| ------------------------------------------------------------- |:----------------:| ---------------------------------:|
| [AlamofireImage](https://github.com/Alamofire/AlamofireImage) | AlamofireSource  | `pod "ImageSlideshow/Alamofire"`  |
| [AFNetworking](https://github.com/AFNetworking/AFNetworking)  | AFURLSource      | `pod "ImageSlideshow/AFURL"`      |
| [SDWebImage](https://github.com/rs/SDWebImage)                | SDWebImageSource | `pod "ImageSlideshow/SDWebImage"` |
| [Kingfisher](https://github.com/onevcat/Kingfisher)           | KingfisherSource | `pod "ImageSlideshow/Kingfisher"` |
| [Parse](https://github.com/ParsePlatform/Parse-SDK-iOS-OSX)   | ParseSource      | `pod "ImageSlideshow/ParseSource"`|


```swift
slideshow.setImageInputs([
  ImageSource(image: UIImage(named: "myImage"))!,
  ImageSource(image: UIImage(named: "myImage2"))!,
  AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080"),
  KingfisherSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080"),
  ParseSource(file: PFFile(name:"image.jpg", data:data))
])
```

### Configuration

Behaviour is configurable by those properties:

- ```slideshowInterval``` - slideshow interval in seconds (default `0` – disabled)
- ```zoomEnabled``` - enables zooming (default `false`)
- ```circular``` - enables circular scrolling (default `true`)
- ```pageControlPosition``` - configures position of UIPageControl (default `insideScrollView`, also `hidden`, `underScrollView` or `custom`)
- ```contentScaleMode``` - configures the scaling (default `ScaleAspectFit`)
- ```draggingEnabled``` - enables dragging (default `true`)
- ```currentPageChanged``` - closure called on page change
- ```willBeginDragging``` - closure called on scrollViewWillBeginDragging
- ```didEndDecelerating``` - closure called on scrollViewDidEndDecelerating
- ```preload``` - image preloading configuration (default `all` preloading, also `fixed`)

### Activity Indicator

By default activity indicator is not shown, but you can enable it by setting `DefaultActivityIndicator` instance to Image Slideshow:

```swift
slideshow.activityIndicator = DefaultActivityIndicator()
```

You can customize style and color of the indicator:

```swift
slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
```

There's also an option to use your own activity indicator. You just need to implement `ActivityIndicatorView` and `ActivityIndicatorFactory` protocols. See `ActivityIndicator.swift` for more information.

### Full Screen view

There is also a possibility to open full-screen image view using attached `FullScreenSlideshowViewController`. The simplest way is to call:

```swift
override func viewDidLoad() {
  let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap))
  slideshow.addGestureRecognizer(gestureRecognizer)
}

func didTap() {
  slideshow.presentFullScreenController(from: self)
}
```

`FullScreenSlideshowViewController` can also be instantiated and configured manually if more advanced behavior is needed.

## 👤 Author

Petr Zvoníček

## 📄 License

ImageSlideshow is available under the MIT license. See the LICENSE file for more info.

## 👀 References

Inspired by projects:
- https://github.com/gonzalezreal/Vertigo
- https://github.com/kimar/KIImagePager
