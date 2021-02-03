# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'RxSwiftReviewDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RxSwiftReviewDemo

  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'

  target 'RxSwiftReviewDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'RxSwiftReviewDemoUITests' do
    # Pods for testing
  end

  
end

post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'RxSwift'
              target.build_configurations.each do |config|
                  if config.name == 'Debug'
                      config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                  end
              end
          end
      end
  end
