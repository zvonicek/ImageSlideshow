#
# Be sure to run `pod lib lint ImageSlideshow.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ImageSlideshow"
  s.version          = "0.1.0"
  s.summary          = "Image slideshow written in Swift with circular scrolling, timer and full screen viewer"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Image slideshow is a Swift library providing customizable image slideshow with circular scrolling, timer and full screen viewer. Optionally also provides downloading images via AFNetworking
                         DESC

  s.homepage         = "https://github.com/zvonicek/ImageSlideshow"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Petr Zvonicek" => "zvonicek@gmail.com" }
  s.source           = { :git => "https://github.com/zvonicek/ImageSlideshow.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zvonicek'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ImageSlideshow' => ['Pod/Assets/*.png']
  }

  s.dependency 'AFNetworking', '~> 2.3'


  s.subspec 'Base' do |base|
  end

  s.subspec 'AFNetworking' do |afnetworking|
#    afnetworking.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DOFFER_AFNETWORKING' }
#    afnetworking.dependency 'AFNetworking', '~> 2.3'
  end

  s.default_subspec = 'Base'

end
