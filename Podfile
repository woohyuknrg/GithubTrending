platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def sharedPods
  pod 'RxSwift', '3.2.0'
  pod 'RxCocoa', '3.2.0'
  pod 'Moya/RxSwift', '8.0.2'
  pod 'SwiftyJSON', '3.1.4'
end

def testPods
  pod 'Quick', '1.1.0'
  pod 'Nimble', '6.0.1'
  pod 'RxBlocking', '3.2.0'
  pod 'RxTest', '3.2.0'
end

target 'github' do
  sharedPods
end

target 'githubTests' do
  sharedPods
  testPods
end
