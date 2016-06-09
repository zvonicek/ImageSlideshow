# Change log

## [0.5](https://github.com/AFNetworking/AFNetworking/releases/tag/0.5) (??/06/2016)

The version 0.5 cleans up the code, adds interactive fullscreen dismiss and fixes few minor issues (thanks again, @kafejo) 
This version also contains several background compatibility breaks, so please keep this in mind when upgrading to it.

### New Features
- Interactive dismiss transition on full screen controller

### API changes
- ImageSlideshow: `currentPage` renamed to `currentItemIndex`
- FullScreenSlideshowViewController: `initialPage` renamed to `initialPageIndex`
- ZoomAnimatedTransitioning: added second parameter `slideshowController: FullScreenSlideshowViewController` to constructor
