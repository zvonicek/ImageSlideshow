# ImageSlideshow

[![CI Status](http://img.shields.io/travis/zvonicek/ImageSlideshow.svg?style=flat)](https://travis-ci.org/zvonicek/ImageSlideshow)
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

## Requirements

## Installation

ImageSlideshow is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImageSlideshow', '~> 0.4'
```

## Usage

You can instantiate Slideshow either in Storyboard / Interface Builder, or in code. 

### Loading images

Images can be set by calling ```setImageInputs``` method on ```ImageSlideshow``` instance. Argument is an array of *InputSource*s. By default you may use ```ImageSource``` which takes ```UIImage```, but you can easily subclass ```InputSource``` and support your own input source.

```swift
slideshow.setImageInputs([ImageSource(image: UIImage(named: "myImage"))!, ImageSource(image: UIImage(named: "myImage2"))!,])
```

There are two more *InputSource*s available:

#### AlamofireImage

*AlamofireSource* subspec for loading image from an URL via *AlamofireImage*. To use this add the Alamofire subspec to your Podfile.

```ruby
pod "ImageSlideshow/Alamofire"
``` 

An image from arbitrary URL is then loaded by *AlamofireSource* initialization.

```swift
AlamofireSource(urlString: "https://upload.wikimedia.org/wikipedia/commons/d/d5/Trencin_hdr_001.jpg")
```

#### AFNetworking

*AFURL* subspec for loading image from an URL via *AFNetworking*. To use this add the AFURL subspec to your Podfile.

```ruby
pod "ImageSlideshow/AFURL"
``` 

An image from arbitrary URL is then loaded by *AFURLSource* initialization.

```swift
AFURLSource(urlString: "https://upload.wikimedia.org/wikipedia/commons/d/d5/Trencin_hdr_001.jpg")
```

### Configuration

It is possible to configure behaviour by setting numerous properties: 

- ```slideshowInterval``` - in case you want automatic slideshow, set up the interval between sliding to next picture
- ```zoomEnabled``` - enables zooming
- ```circular``` - enables circular scrolling
- ```pageControlPosition``` - configures position of UIPageControll (hidden, inside scroll view or under scroll view)
- ```contentScaleMode``` - configures the scaling (UIViewContentMode.ScaleAspectFit by default)
- ```draggingEnabled``` - enables dragging

### Full Screen view

As seen on sample image and example project, you may also use full-scren view. The controller can be presented manually as seen on the example. 

```swift
var transitionDelegate: ZoomAnimatedTransitioningDelegate?

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
  ctr.initialPage = slideshow.scrollViewPage
  // set the inputs
  ctr.inputs = slideshow.images
  self.transitionDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow, slideshowController: ctr)
  ctr.transitioningDelegate = self.transitionDelegate
  self.presentViewController(ctr, animated: true, completion: nil)
}
```

## Author

Petr Zvoníček, zvonicek@gmail.com

## License

ImageSlideshow is available under the MIT license. See the LICENSE file for more info.

### References

Inspired by projects: 
- https://github.com/gonzalezreal/Vertigo
- https://github.com/kimar/KIImagePager
