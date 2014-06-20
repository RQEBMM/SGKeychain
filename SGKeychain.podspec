Pod::Spec.new do |s|
  s.name             = "SGKeychain"
  s.version          = '1.0.0'
  s.summary          = "SGKeychain is a class for working with the keychain on iOS and OS X."
  s.description      = <<-DESC
                       SGKeychain is a class for working with the keychain on iOS and OS X. It has the following features:

                       * Creating new keychain items
                       * Fetching passwords from the keychain
                       * Deleting items from your keychain
                       * Supports keychain access groups for sharing a single keychain between multiple apps (not supported in the iPhone simulator)
                       * Built for iOS 7/10.8 and above using automatic reference counting (ARC)
                       * Unit tested
                       DESC
  s.homepage         = "https://github.com/secondgear/SGKeychain"
  s.license          = 'MIT'
  s.author           = { "Justin Williams" => "justinw@me.com" }
  s.source           = { :git => "https://github.com/secondgear/SGKeychain.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/justin'

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.frameworks = 'Security'
end
