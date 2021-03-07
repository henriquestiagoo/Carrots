Pod::Spec.new do |spec|

  spec.name         = "Carrots"
  spec.version      = "1.0.0"
  spec.summary      = "A scalable and easy to use HTTP client written in Swift."
  spec.homepage     = "https://github.com/henriquestiagoo/Carrots.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Tiago Henriques" => "th.tk@hotmail.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = "11.0"
  spec.osx.deployment_target = "10.13"
  spec.watchos.deployment_target = "4.0"
  spec.tvos.deployment_target = "11.0"
  spec.source       = { :git => "https://github.com/henriquestiagoo/Carrots.git", :tag => "#{spec.version}" }
  spec.swift_version = '5.0'
  spec.source_files = "Sources/Carrots/*.swift"
  spec.dependency 'Logging', '~> 1.4.0'

end
