platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def sharedPods
  pod 'RxSwift', '~> 2.0'
  pod 'RxCocoa', '~> 2.0'
  pod 'Moya/RxSwift', '7.0.0'
  pod 'SwiftyJSON', '2.3.2'
end

def testPods
  pod 'Quick', '0.9.3'
  pod 'Nimble', '4.1.0'
  pod 'RxBlocking', '~> 2.0'
  pod 'RxTests', '~> 2.0'
end

target 'github' do
  sharedPods
end

target 'githubTests' do
  sharedPods
  testPods
end
