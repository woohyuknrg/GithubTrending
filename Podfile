platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def sharedPods
  pod 'RxSwift', '4.1.2'
  pod 'RxCocoa', '4.1.2'
  pod 'Moya/RxSwift', '11.0.0'
  pod 'SwiftyJSON', '4.0.0'
end

def testPods
  pod 'Quick', '1.2.0'
  pod 'Nimble', '7.0.3'
  pod 'RxBlocking', '4.1.2'
  pod 'RxTest', '4.1.2'
end

target 'github' do
  sharedPods
end

target 'githubTests' do
  sharedPods
  testPods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
