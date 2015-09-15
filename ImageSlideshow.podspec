#
# Be sure to run `pod lib lint ImageSlideshow.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ImageSlideshow"
  s.version          = "0.2.2"
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
  s.screenshots     = "http://cl.ly/image/2v193I0G0h0Z/ImageSlideshow2.gif"
  s.license          = 'MIT'
  s.author           = { "Petr Zvonicek" => "zvonicek@gmail.com" }
  s.source           = { :git => "https://github.com/zvonicek/ImageSlideshow.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zvonicek'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.subspec 'Core' do |core|
    core.source_files = 'Pod/Classes/Core/**/*'
    core.resource_bundles = {
        'ImageSlideshow' => ['Pod/Assets/*.png']
    }
  end

  s.subspec 'AFURL' do |afnetworking|
    afnetworking.dependency 'ImageSlideshow/Core'
    afnetworking.dependency 'AFNetworking', '~> 2.3'
    afnetworking.source_files = 'Pod/Classes/InputSources/AFURLSource.swift'
  end

  s.default_subspec = 'Core'

end
