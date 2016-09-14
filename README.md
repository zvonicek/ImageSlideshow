# ImageSlideshow

[![Version](https://img.shields.io/cocoapods/v/ImageSlideshow.svg?style=flat)](http://cocoapods.org/pods/ImageSlideshow)
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

Version 0.5 currently supports Swift 2.2. Code compatible with newer versions can be found in branches *swift-2.3* and *swift-3*. Currently only ImageSlideshow itself and AFNetworking extension is supported, support for Alamofire and SDWebImage will be added shortly. Eventually, the swift-3 branch will be merged into master and released as an update.


## Installation

ImageSlideshow is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImageSlideshow', '~> 0.5'
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
SDWebImageSource(urlString: "httpshttps://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")
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
  ...
  let gestureRecognizer = UITapGestureRecognizer(target: self, action: "openFullScreen")
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
  self.presentViewController(ctr, animated: true, completion: nil)
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
