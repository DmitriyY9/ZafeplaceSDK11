Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "ZafeplaceSDK"
s.summary = "Description"
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Dmitriy Yurchenko" => "yurchenko.d@ideasoft.io" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/TheCodedSelf/RWPickFlavor"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/DmitriyY9/ZafeplaceSDK.git",
             :tag => "0.1.0" }

# 7
s.framework = "UIKit"
s.dependency 'stellar-ios-mac-sdk', '~> 1.5.6'
s.dependency 'web3swift', :git => 'https://github.com/bankex/web3swift.git'

# 8
s.source_files = "ZafeplaceSDK/**/*.{swift}"

# 9
s.resources = "ZafeplaceSDK/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "4.2"

end
