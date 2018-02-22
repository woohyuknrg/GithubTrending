import Quick
import Nimble
import RxBlocking
import RxSwift
import RxCocoa
import RxTest
import Moya
@testable import github

class SearchViewModelSpec: QuickSpec {
    override func spec() {
        var sut: SearchViewModel!
        var scheduler: TestScheduler!
        
        beforeEach {
            scheduler = TestScheduler(initialClock: 0)
            SharingScheduler.mock(scheduler: scheduler) {
                sut = SearchViewModel(provider: MoyaProvider(stubClosure: MoyaProvider.immediatelyStub))
            }
        }
        
        afterEach {
            scheduler = nil
            sut = nil
        }
        
        it ("returns valid title") {
            expect(sut.title) == "Search"
        }
        
    }
}
