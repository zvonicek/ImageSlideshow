# ImageSlideshow

[![Build Status](https://www.bitrise.io/app/9aaf3e552f3a575c.svg?token=AjiVckTN9ItQtJs873mYMw&branch=master)](https://www.bitrise.io/app/9aaf3e552f3a575c)
[![Version](https://img.shields.io/cocoapods/v/ImageSlideshow.svg?style=flat)](http://cocoapods.org/pods/ImageSlideshow)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/ImageSlideshow.svg?style=flat)](http://cocoapods.org/pods/ImageSlideshow)
[![Platform](https://img.shields.io/cocoapods/p/ImageSlideshow.svg?style=flat)](http://cocoapods.org/pods/ImageSlideshow)

# ImageSlideshow

iOS / Swift image slideshow with circular scrolling, timer and full screen viewer.

![](http://cl.ly/image/2v193I0G0h0Z/ImageSlideshow2.gif)


This component is under development. Description and brief documentation will follow with future versions. The API will be subject of change.

Roadmap for 1.0:
- ~~Create test project~~
- ~~Create CocoaPod~~
- ~~Fix initial bugs~~
- Polish API
- Write brief documentation
- Improve the example project to demonstrate all the features
- ~~*InputSource* subclass for *Alamofire* (yay!)~~

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Swift 2.3 and Swift 3 support

Version 0.6 supports both Swift 2.2 and Swift 2.3. Code compatible with Swift 3 can be found in experimental branch *swift-3*. 

## Installation

### CocoaPods
ImageSlideshow is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImageSlideshow', '~> 0.6'
```

### Carthage
To integrate ImageSlideshow into your Xcode project using Carthage, specify it in your Cartfile: 

```ruby
github "zvonicek/ImageSlideshow" ~> 0.6
```

## Usage

You can instantiate Slideshow either in Storyboard / Interface Builder, or in code. 

### Loading images

Images can be set by calling ```setImageInputs``` method on ```ImageSlideshow``` instance. Argument is an array of *InputSource*s. By default you may use ```ImageSource``` which takes ```UIImage```, but you can easily subclass ```InputSource``` and support your own input source.

```swift
slideshow.setImageInputs([
  ImageSource(image: UIImage(named: "myImage"))!, 
  ImageSource(image: UIImage(named: "myImage2"))!
])
```

There are three more *InputSource*s available:

#### AlamofireImage

```ruby
pod "ImageSlideshow/Alamofire"
``` 

Used by creating a new `AlamofireSource` instance:
```swift
AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")
```

#### AFNetworking

```ruby
pod "ImageSlideshow/AFURL"
``` 

Used by creating a new `AFURLSource` instance:
```swift
AFURLSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")
```

#### SDWebImage

```ruby
pod "ImageSlideshow/SDWebImage"
``` 

Used by creating a new `SDWebImageSource` instance:
```swift
SDWebImageSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")
```

#### Kingfisher

```ruby
pod "ImageSlideshow/Kingfisher"
```
Used by creating a new `KingfisherSource` instance:
```swift
KingfisherSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")
```
### Configuration

Behaviour is configurable by those properties:

- ```slideshowInterval``` - in case you want automatic slideshow, set up the interval between sliding to next picture
- ```zoomEnabled``` - enables zooming
- ```circular``` - enables circular scrolling
- ```pageControlPosition``` - configures position of UIPageControll (hidden, inside scroll view or under scroll view)
- ```contentScaleMode``` - configures the scaling (UIViewContentMode.ScaleAspectFit by default)
- ```draggingEnabled``` - enables dragging

### Full Screen view

There is also a possibility to open full-screen image view using attached `FullScreenSlideshowViewController`. The controller is meant to be presented manually, as seen on the example:

```swift
var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate?

override func viewDidLoad() {
  //...
  let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.click))
  slideshow.addGestureRecognizer(gestureRecognizer)
}

func click() {
  let ctr = FullScreenSlideshowViewController()
  // called when full-screen VC dismissed and used to set the page to our original slideshow
  ctr.pageSelected = {(page: Int) in
    self.slideshow.setScrollViewPage(page, animated: false)
  }

  // set the initial page
  ctr.initialImageIndex = slideshow.scrollViewPage
  // set the inputs
  ctr.inputs = slideshow.images
  self.slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow, slideshowController: ctr)
  ctr.transitioningDelegate = self.slideshowTransitioningDelegate
  self.present(ctr, animated: true, completion: nil)
}
```

## Author

Petr Zvoníček

## License

ImageSlideshow is available under the MIT license. See the LICENSE file for more info.

### References

Inspired by projects: 
- https://github.com/gonzalezreal/Vertigo
- https://github.com/kimar/KIImagePager
