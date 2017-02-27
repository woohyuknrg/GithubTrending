import Quick
import Nimble
import RxBlocking
import RxSwift
import RxCocoa
import RxTest
import Moya
@testable import github

class LoginViewModelSpec: QuickSpec {
    override func spec() {
        var sut: LoginViewModel!
        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            driveOnScheduler(scheduler) {
                sut = LoginViewModel(provider: RxMoyaProvider(stubClosure: MoyaProvider.immediatelyStub))
            }
            disposeBag = DisposeBag()
        }
        afterEach {
            scheduler = nil
            sut = nil
            disposeBag = nil
        }
        
        it("should enable UI elements when valid login credentials are entered") {
            let observer = scheduler.createObserver(Bool.self)


            scheduler.scheduleAt(100) {
                sut.loginEnabled.asObservable().subscribe(observer).disposed(by: disposeBag)

            }
            
            scheduler.scheduleAt(200) {
                sut.username.value = "johny"
                sut.password.value = "yellowpanties"
            }

            scheduler.start()

            let results = observer.events
                .map { event in
                    event.value.element!
            }
            
            expect(results) == [false, false, true]
        }
        
        it("should make network request and return error when valid login credentials are entered") {
            let results = scheduler.createObserver(LoginResult.self)
            
            scheduler.scheduleAt(100) {
                sut.loginFinished.asObservable().subscribe(results).disposed(by: disposeBag)
            }
            
            scheduler.scheduleAt(200) {
                sut.username.value = "johny"
                sut.password.value = "yellowpanties"
                sut.loginTaps.onNext(())
            }
            
            scheduler.start()
            
            XCTAssertEqual(results.events,
                [
                    next(201, LoginResult.failed(message: "Oops, something went wrong")),
                    completed(201)
                ])
        }
        
        it("should not enable UI elements when invalid credentials are entered") {
            let observer = scheduler.createObserver(Bool.self)
            
            scheduler.scheduleAt(100) {
                sut.loginEnabled.asObservable().subscribe(observer).disposed(by: disposeBag)
            }
            
            scheduler.scheduleAt(200) {
                sut.username.value = "a"
                sut.password.value = "b"
            }
            
            scheduler.start()
            
            let results = observer.events
                .map { event in
                    event.value.element!
                }
            
            expect(results) == [false, false, false]
        }
        /*
        it("normal test") {
            let xs = scheduler.createHotObservable([
                next(150, 1),
                next(210, 0),
                next(220, 1),
                next(230, 2),
                next(240, 4),
                completed(300)
                ])
            let res = scheduler.start { xs.map { $0 * 2 } }
            let correctEvents = [
                next(210, 0 * 2),
                next(220, 1 * 2),
                next(230, 2 * 2),
                next(240, 4 * 2),
                completed(300)
            ]
            let correctSubscriptions = [
                Subscription(200, 300)
            ]

            XCTAssertEqual(res.events, correctEvents)
            XCTAssertEqual(xs.subscriptions, correctSubscriptions)
        }
 */
    }
}
