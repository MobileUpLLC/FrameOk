Pod::Spec.new do |spec|

  spec.name         = "FrameOk"
  spec.version      = "1.0.0"
  spec.summary      = "FrameOk is a set of MobileUp tools that is used in developing mobile applications for the iOS platform"
  spec.description  = "It also includes Mutal, a useful debugging utility that can simulate network errors, autocomplete form fields, view logs, change the backend environment, and run custom debug scripts."
  spec.homepage     = "https://github.com/MobileUpLLC/FrameOk"

  spec.license      = "MIT"
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.authors      = { "Dmitry Smirnov, MobileUp" => "ds@mobileup.ru", "Maxim Aliev, MobileUp" => "ma@mobileup.ru", "Ilia Biltuev, MobileUp" => "ib@mobileup.ru", "Nikolai Timonin, MobileUp" => "nt@mobileup.ru", "Pavel Petrovich, MobileUp" => "pp@mobileup.ru" }

  spec.platform     = :ios, "10.0"
  spec.ios.frameworks = 'UIKit'
  spec.swift_version = ['4.2', '5']
  
  spec.source = { :git => 'https://github.com/MobileUpLLC/FrameOK.git', :tag => spec.version.to_s }
  spec.source_files  = "Source/", "Source/**/*.{swift}"
  spec.module_name   = 'FrameOk'

  spec.dependency 'Alamofire', '~> 4.9'
  spec.dependency 'AlamofireNetworkActivityIndicator'
  spec.dependency 'AlamofireNetworkActivityLogger'
  spec.dependency 'Kingfisher'
  spec.dependency 'PhoneNumberKit'
  spec.dependency 'XCGLogger'
  spec.dependency 'GCDWebServer', '~> 3.0'
  spec.dependency 'SkeletonView'
  spec.dependency 'SwiftEntryKit'
  spec.dependency 'InputMask', '~> 4.3.0'

end
