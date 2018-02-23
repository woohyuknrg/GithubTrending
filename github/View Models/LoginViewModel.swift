import Foundation
import RxSwift
import RxCocoa
import Moya

class LoginViewModel {
    // Input
    var username = BehaviorRelay(value: "")
    var password = BehaviorRelay(value: "")
    var loginTaps = PublishSubject<Void>()
    
    // Output
    let loginEnabled: Driver<Bool>
    let loginFinished: Driver<LoginResult>
    let loginExecuting: Driver<Bool>
    
    // Private
    fileprivate let provider: MoyaProvider<GitHub>
    
    init(provider: MoyaProvider<GitHub>) {
        self.provider = provider
        
        let activityIndicator = ActivityIndicator()
        loginExecuting = activityIndicator
            .asDriver()
        
        let usernameObservable = username.asObservable()
        let passwordObservable = password.asObservable()
        
        loginEnabled = Observable.combineLatest(usernameObservable, passwordObservable)
            { $0.count > 0 && $1.count > 6 }
            .asDriver(onErrorJustReturn: false)
        
        let usernameAndPassword = Observable.combineLatest(usernameObservable, passwordObservable)
            { ($0, $1) }
        
        loginFinished = loginTaps
            .withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                provider.rx.request(GitHub.token(username: username,
                                                 password: password,
                                                 scopes: ["public_repo", "user"],
                                                 note: "Ori iOS app (\(Date()))"))
                    .retry(3)
                    .trackActivity(activityIndicator)
                    .observeOn(MainScheduler.instance)
            }
            .checkIfRateLimitExceeded()
            .mapJSON()
            .do(onNext: { json in
                var appToken = Token()
                appToken.token = (json as? [String: Any])?["token"] as? String
            })
            .map { json in
                if let message = (json as? [String: Any])?["message"] as? String {
                    return LoginResult.failed(message: message)
                } else {
                    return LoginResult.ok
                }
            }
            .asDriver(onErrorJustReturn: LoginResult.failed(message: "Oops, something went wrong")).debug()
    }
}
