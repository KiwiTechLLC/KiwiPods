# KiwiPods

To integrate Kiwipods in your app add `pod 'KiwiPods', :git => 'https://github.com/KiwiTechLLC/KiwiPods.git'` to your pod file.   
KiwiPods are supported for `Swift 4.2` and `iOS 11.0 and above`  


In case `Social` or `Google` depandency is needed, add following code in `podfile` :  
```
pre_install do |installer|
# workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['KiwiPods'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['MACH_O_TYPE'] = 'staticlib'
      end
    end
    if ['AWSMobileClient'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
```
