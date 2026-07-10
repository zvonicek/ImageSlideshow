#
# Be sure to run `pod lib lint ImageSlideshow.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ImageSlideshow"
  s.version          = "1.9.4"
  s.summary          = "Image slideshow written in Swift with circular scrolling, timer and full screen viewer"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Image slideshow is a Swift library providing customizable image slideshow with circular scrolling, timer and full screen viewer and extendable image source (AFNetworking image source available in AFURL subspec).
                         DESC

  s.homepage         = "https://github.com/zvonicek/ImageSlideshow"
  s.screenshots     = "https://dzwonsemrish7.cloudfront.net/items/2R06283n040V3P3p0i42/ezgif.com-optimize.gif"
  s.license          = 'MIT'
  s.author           = { "Petr Zvonicek" => "zvonicek@gmail.com" }
  s.source           = { :git => "https://github.com/zvonicek/ImageSlideshow.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zvonicek'

  s.swift_versions = ['5', '5.1', '5.2', '5.10', '6.0', '6.1']
  s.platform     = :ios, '15.0'
  s.requires_arc = true

  s.subspec 'Core' do |core|
    core.source_files = 'ImageSlideshow/Classes/Core/**/*'
    core.resources = 'ImageSlideshow/Assets/*.png'
  end

  s.subspec 'AFURL' do |subspec|
    subspec.dependency 'ImageSlideshow/Core'
    subspec.dependency 'AFNetworking', '~> 4.0'
    subspec.source_files = 'ImageSlideshow/Classes/InputSources/AFURLSource.swift'
  end

  s.subspec 'Alamofire3' do |subspec|
    subspec.dependency 'ImageSlideshow/Core'
    subspec.dependency 'AlamofireImage', '~> 3.0'
    subspec.source_files = 'ImageSlideshow/Classes/InputSources/AlamofireLegacySource.swift'
  end

  s.subspec 'Alamofire' do |subspec|
    subspec.dependency 'ImageSlideshow/Core'
    subspec.dependency 'AlamofireImage', '~> 4.0'
    subspec.source_files = 'ImageSlideshow/Classes/InputSources/AlamofireSource.swift'
  end

  s.subspec 'SDWebImage' do |subspec|
    subspec.dependency 'ImageSlideshow/Core'
    subspec.dependency 'SDWebImage', '>= 5.1'
    subspec.source_files = 'ImageSlideshow/Classes/InputSources/SDWebImageSource.swift'
  end

  s.subspec 'Kingfisher' do |subspec|
    subspec.dependency 'ImageSlideshow/Core'
    subspec.dependency 'Kingfisher', '>= 8.3.2'
    subspec.source_files = 'ImageSlideshow/Classes/InputSources/KingfisherSource.swift'
  end

  s.default_subspec = 'Core'

end
