# 🖼 MediaSlideshow
**Customizable Swift image & video slideshow with circular scrolling, timer and full screen viewer**

The this is a fork of [ImageSlideshow](https://github.com/zvonicek/ImageSlideshow) aimed at supporting video.

## 📱 Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## 🔧 Installation

### CocoaPods
MediaSlideshow is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MediaSlideshow', '~> 1.9.2'
```

### Carthage
To integrate MediaSlideshow into your Xcode project using Carthage, specify it in your Cartfile:

```ruby
github "pm-dev/MediaSlideshow" ~> 1.9.2
```

Carthage does not include InputSources for external providers (due to dependency on those providers) so you need to grab the one you need from `MediaSlideshow/Classes/InputSources` manually.


**Note on Swift 2.3, Swift 3 and Swift 4 support**

Version 1.4 supports Swift 4. Swift 3 is supported from version 1.0, for Swift 2.2 and Swift 2.3 compatible code use version 0.6 or branch *swift-2.3*.


## 🔨 How to use

Add MediaSlideshow view to your view hiearchy either in Interface Builder or in code.

### Loading images

Set images by using ```dataSource``` property on ```MediaSlideshow``` instance and calling `reloadData()`. The datasource requires
`MediaSource` inputs. You can use ```UIImageSource``` which takes ```UIImage``` or few other *InputSource*s for most popular networking libraries. You can also create your own input source by implementing ```ImageSource``` protocol.

| Library                                                       | InputSource name | Pod                               |
| ------------------------------------------------------------- |:----------------:| ---------------------------------:|
| [AlamofireImage](https://github.com/Alamofire/AlamofireImage) | AlamofireSource  | `pod "MediaSlideshow/Alamofire"`  |
| [AFNetworking](https://github.com/AFNetworking/AFNetworking)  | AFURLSource      | `pod "MediaSlideshow/AFURL"`      |
| [SDWebImage](https://github.com/rs/SDWebImage)                | SDWebImageSource | `pod "MediaSlideshow/SDWebImage"` |
| [Kingfisher](https://github.com/onevcat/Kingfisher)           | KingfisherSource | `pod "MediaSlideshow/Kingfisher"` |
| [Parse](https://github.com/ParsePlatform/Parse-SDK-iOS-OSX)   | ParseSource      | `pod "MediaSlideshow/Parse"`      |


```swift

let dataSource = ImageSlideshowDataSource(inputs:[
    UIImageSource(image: UIImage(named: "myImage"))!,
    UIImageSource(image: UIImage(named: "myImage2"))!,
    AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080"),
    KingfisherSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080"),
    ParseSource(file: PFFile(name:"image.jpg", data:data))
])

slideshow.dataSource = dataSource
slideshow.reloadData()

```

### Loading videos

MediaSlideshow also supports playing an AVAsset. Make sure to include the "MediaSlideshow/AV" dependency.

```swift

let dataSource = ImageAndVideoSlideshowDataSource(inputs:[
    UIImageSource(image: UIImage(named: "myImage"))!,
    AVInputSource(url: "https://url-to-video", autoplay: true)
])

slideshow.dataSource = dataSource
slideshow.reloadData()
```


### Configuration

MediaSlideshow behaviour is configurable by those properties:

- ```slideshowInterval``` - slideshow interval in seconds (default `0` – disabled)
- ```zoomEnabled``` - enables zooming (default `false`)
- ```circular``` - enables circular scrolling (default `true`)
- ```activityIndicator``` – allows to set custom activity indicator, see *Activity indicator* section
- ```pageIndicator``` – allows to set custom page indicator, see *Page indicator* section; assign `nil` to hide page indicator
- ```pageIndicatorPosition``` - configures position of the page indicator
- ```contentScaleMode``` - configures the scaling (default `ScaleAspectFit`)
- ```draggingEnabled``` - enables dragging (default `true`)
- ```currentPageChanged``` - closure called on page change
- ```willBeginDragging``` - closure called on scrollViewWillBeginDragging
- ```didEndDecelerating``` - closure called on scrollViewDidEndDecelerating
- ```preload``` - image preloading configuration (default `all` preloading, also `fixed`)

### Page Indicator

Page indicator can be customized using the `pageIndicator` property on MediaSlideshow. By defualt, a plain UIPageControl is used. If needed, page control can be customized:

```swift
let pageIndicator = UIPageControl()
pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
pageIndicator.pageIndicatorTintColor = UIColor.black
slideshow.pageIndicator = pageIndicator
```

Also, a simple label page indicator that shows pages in style "5/21" (fifth page from twenty one) is provided:

```swift
slideshow.pageIndicator = LabelPageIndicator()
```

You can also use your own page indicator by adopting the `PageIndicatorView` protocol.

Position of the page indicator can be configured by assigning a `PageIndicatorPosition` value to the `pageIndicatorPosition` property on MediaSlideshow. You may specify the horizontal and vertical positioning separately.

**Horizontal** positioning options are: `.left(padding: Int)`, `.center`, `.right(padding: Int)`

**Vertical** positioning options are: `.top`, `.bottom`, `.under`, `customTop(padding: Int)`, `customBottom(padding: Int)`, `customUnder(padding: Int)`

Example:
```swift
slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .left(padding: 20), vertical: .bottom)
```


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
Peter Meyers

## 📄 License

MediaSlideshow is available under the MIT license. See the LICENSE file for more info.

## 👀 References

Inspired by projects:
- https://github.com/gonzalezreal/Vertigo
- https://github.com/kimar/KIImagePager
