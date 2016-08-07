require 'json'

package = JSON.parse(File.read(File.join(__dir__, '../package.json')))

Pod::Spec.new do |s|
  s.name          = "react-native-image-cropper"
  s.version       = package['version']
  s.license       = "MIT"
  s.homepage      = "https://github.com/WitzHsiao/react-native-image-cropper"
  s.authors       = { 'Witz Hsiao' => 'witz.hsiao@gmail.com' }
  s.summary       = "a cropping view controller"
  s.source        = { :git => "https://github.com/WitzHsiao/react-native-image-cropper.git",
                      :tag => "#{s.version}" }
  s.source_files  = "ImageCropper/*.{h,m}"

  s.platform      = :ios, "8.0"
  s.dependency 'React'
  s.dependency 'RSKImageCropper', '1.5.1'
  s.dependency 'UIImage-Resize', '~> 1.0'
end
