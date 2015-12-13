use_frameworks!
target 'uMAD' do

pod 'Parse'
pod 'ParseUI'
pod 'Fabric'
pod 'TwitterKit'
pod 'TwitterCore'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-uMAD/Pods-uMAD-acknowledgements.plist', 'uMAD/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

end

