#
# Be sure to run `pod lib lint MediaSlideshow.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MediaSlideshow"
  s.version          = "1.9.2"
  s.summary          = "Image (and optionally, video) slideshow written in Swift with circular scrolling, timer and full screen viewer"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Media slideshow is a Swift library providing customizable image (and optionally, video) slideshow with circular scrolling, timer and full screen viewer and extendable media source (AFNetworking image source available in AFURL subspec).
                         DESC

  s.homepage         = "https://github.com/pm-dev/MediaSlideshow"
  s.screenshots     = "https://dzwonsemrish7.cloudfront.net/items/2R06283n040V3P3p0i42/ezgif.com-optimize.gif"
  s.license          = 'MIT'
  s.author           = { "Petr Zvonicek" => "zvonicek@gmail.com" }
  s.source           = { :git => "https://github.com/pm-dev/MediaSlideshow.git", :tag => s.version.to_s }

  s.swift_versions = ['4.0', '4.1', '4.2', '5', '5.1', '5.2']
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.subspec 'Core' do |core|
    core.source_files = 'MediaSlideshow/Classes/Core/**/*'
    core.resources = 'MediaSlideshow/Assets/*.png'
  end

  s.subspec 'AFURL' do |subspec|
    subspec.dependency 'MediaSlideshow/Core'
    subspec.dependency 'AFNetworking', '~> 3.0'
    subspec.source_files = 'MediaSlideshow/Classes/InputSources/AFURLSource.swift'
  end

  s.subspec 'Alamofire3' do |subspec|
    subspec.dependency 'MediaSlideshow/Core'
    subspec.dependency 'AlamofireImage', '~> 3.0'
    subspec.source_files = 'MediaSlideshow/Classes/InputSources/AlamofireLegacySource.swift'
  end

  s.subspec 'Alamofire' do |subspec|
    subspec.dependency 'MediaSlideshow/Core'
    subspec.dependency 'AlamofireImage', '~> 4.0'
    subspec.platform     = :ios, '10.0'
    subspec.source_files = 'MediaSlideshow/Classes/InputSources/AlamofireSource.swift'
  end

  s.subspec 'SDWebImage' do |subspec|
    subspec.dependency 'MediaSlideshow/Core'
    subspec.dependency 'SDWebImage', '>= 3.7'
    subspec.source_files = 'MediaSlideshow/Classes/InputSources/SDWebImageSource.swift'
  end

  s.subspec 'Kingfisher' do |subspec|
    subspec.dependency 'MediaSlideshow/Core'
    subspec.dependency 'Kingfisher', '> 3.0'
    subspec.platform     = :ios, '10.0'
    subspec.source_files = 'MediaSlideshow/Classes/InputSources/KingfisherSource.swift'
  end

  s.subspec 'Parse' do |subspec|
    subspec.dependency 'MediaSlideshow/Core'
    subspec.dependency 'Parse', '~> 1.14'
    subspec.source_files = 'MediaSlideshow/Classes/InputSources/ParseSource.swift'
  end

  s.default_subspec = 'Core'

end
