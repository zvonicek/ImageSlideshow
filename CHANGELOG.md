# Change log

## 1.0 (?)

Version 1.0 aims to improve stability and brings couple of new features. Also contains few backward complatibility breaking changes.

## New Features
- New input source for Kingfisher (thanks @feiin)
- Add `currentPageChanged` closure to notify about page change (#54)
- Add possibility to lazy load and release images (#42)
- Easier way to present `FullScreenSlideshowViewController` (#72)

## Fixes
- Fix the case when containing VC automatically adjusts scrollview insets (#71)
- Fix crash during transition when no images set (#74) 

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
