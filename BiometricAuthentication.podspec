Pod::Spec.new do |s|
s.name             = 'BiometricAuthentication'
s.version          = '1.1.0'
s.summary          = 'A lightweight, testable wrapper to support biometric authentication in iOS'
s.description      = <<-DESC
Easily integrate FaceID and TouchID with your SwiftUI apps through this library. Use the included mock to also 
support unit and UI testing of these features.
DESC
s.author = { "Sean McNeil" => "mcneilsean@noname.com" }
s.homepage         = 'https://github.com/seanmcneil/BiometricAuthentication'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.source           = { :git => 
'https://github.com/seanmcneil/BiometricAuthentication.git', :tag => s.version.to_s }
s.swift_versions   = '5.5'
s.ios.deployment_target = '13.0'

s.source_files = 'Sources/**/*'
end

