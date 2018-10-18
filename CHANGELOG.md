# Change log

## [1.6.1](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.6.1) (11/06/2018)

## Fixes

- Fixed Carthage build (#258)
- Fixed memory issues (#255)

## [1.6.0](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.6.0) (27/05/2018)

## New Features

- Page Indicator customization (#251)

## Fixes

- Fixed animation problem on orientation change (#234)
- Fixed missing close button image in Carthage build (#247)

## [1.5.3](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.5.3) (17/04/2018)

## Fixes

- Fixed Close broken button in Full screen controller (#242)
- Fixed retain cycle (#241, @piercifani)

## [1.5.2](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.5.2) (16/04/2018)

## New Features

- Example project demonstrating usage of Image Slideshow with parent UIImageView

## Fixes

-  Fix image shift on iPhone X landscape (#200)
-  Add closeButtonFrame property to Full Screen controller (#226)
-  Don't trigger interactive gesture recognizer on horizontal pans, fixes single image sliding issue (#224)
-  Fix interactive dismiss regression on iOS 11 

## [1.5.1](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.5.1) (04/02/2018)

## Fixes
-  Fix division by zero error (#223) 

## [1.5.0](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.5.0) (21/01/2018)

## New Features

- Implement image load cancelling to optimize memory usage
- Improve Kingfisher InputSource to take Options parameters
- Update page control selected page during scrolling (#204)
- Add possibility to change maximum zoom scale (#221)

## Fixes

- SDWebImage dependency improvements (#205)
- Fix possible division by zero crash (#187)
- Adjust close button frame to respect SafeAreaInsets (#209)
- Fix missing placeholder on AFURLSource (#218) 
- Fix incorrect currentPageChanged calls (#222) 

## [1.4.1](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.4.1) (04/10/2017)

## Fixes

- iPhone X fixes


## [1.4.0](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.4.0) (23/09/2017)

## New Features

- Support for Swift 4

## [1.3.0](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.3.0) (08/05/2017)

## New Features

- Possibility to show activity indicator during async loading
- Hide UIPageControl when sllideshow has single item
- UIScrollViewDelegate methods are now `open` instead of `public`

## Fixes

- Fix zoom transition for when a slideshow has just a single item
- Fix issue on `zoomEnabled` change


## [1.2.0](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.2.0) (20/03/2017)

## New Features

- Improved placeholder handling on all remote input sources
- Deprecated `pauseTimerIfNeeded` and `unpauseTimerIfNeeded` in favour of `pauseTimer` and `unpauseTimer`

## Fixes

- Fix memory leak caused by incorrect timer invalidation
- Partially fix an UI glitch happening when "in-call" status bar is on

## [1.1.0](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.1.0) (19/02/2017)

## New Features

- Add `willBeginDragging` and `didEndDecelerating` callback closures (@El-Fitz)
- Add Parse input source (@jaimeagudo)

## Fixes

- Fix image preload issue when scrolling between edges (#115)
- Fix issue caused by disabling `circular` after setting input sources (#104)
- Improve example project
- Style fixes (@dogo)

## [1.0.0](https://github.com/zvonicek/ImageSlideshow/releases/tag/1.0.0) (11/12/2016)

Version 1.0 aims to improve stability and brings couple of new features. Also contains few backward complatibility breaking changes.

## New Features
- New input source for Kingfisher (@feiin)
- Add `currentPageChanged` closure to notify about page change (#54)
- Add possibility to lazy load and release images (#42)
- Easier way to present `FullScreenSlideshowViewController` (#72)
- Documentation improvements

## Fixes
- Fix the case when containing VC automatically adjusts scrollview insets (#71)
- Fix crash during transition when no images set (#74) 
- Rounding error fix for page calculation (#90, @mjrehder)
- Fix for black image when using fullscreen zoom (#92, @mjrehder)
- Change page on UIPageControl page change (#80)
- iOS 10 interactive transition interruption fix (5d5f22f)
- Memory fixes

## API changes
- `currentItemIndex` was renamed to `currentPage`
- `set` function from `InputSource` protocol was renamed to `load` and have a new closure parameter called on image load


## [0.6](https://github.com/zvonicek/ImageSlideshow/releases/tag/0.6.0) (21/06/2016)

Add support for Swift 2.3 and Carthage. Equivalent version *0.6-swift3* supports Swift 3.

## [0.5](https://github.com/zvonicek/ImageSlideshow/releases/tag/0.5.0) (09/06/2016)

The version 0.5 cleans up the code, adds interactive fullscreen dismiss and fixes few minor issues (thanks again, @kafejo) 
This version also contains several background compatibility breaks, so please keep this in mind when upgrading to it.

### New Features
- Interactive dismiss transition on full screen controller
- A possibility to open full screen controller from plain UIImageView

### API changes
- ImageSlideshow: `currentPage` renamed to `currentItemIndex`
- FullScreenSlideshowViewController: `initialPage` renamed to `initialPageIndex`
- ZoomAnimatedTransitioning: added second parameter `slideshowController: FullScreenSlideshowViewController` to constructor
