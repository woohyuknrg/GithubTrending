import Foundation
import RxSwift
import RxCocoa
import Moya

class DiscoverViewModel {
    
    var triggerRefresh = PublishSubject<Void>()
    var selectedItem = PublishSubject<IndexPath>()
    
    let results: Driver<[RepoCellViewModel]>
    let noResultsFound: Driver<Bool>
    let executing: Driver<Bool>
    let selectedViewModel: Driver<RepositoryViewModel>
    let title = "Trending"
    
    fileprivate let repos: BehaviorRelay<[Repo]>
    fileprivate let provider: MoyaProvider<GitHub>
    
    init(provider: MoyaProvider<GitHub>) {
        self.provider = provider
        
        let activityIndicator = ActivityIndicator()
        self.executing = activityIndicator.asDriver().distinctUntilChanged()

        let noResultFoundSubject = BehaviorRelay(value: false)
        self.noResultsFound = noResultFoundSubject.asDriver().distinctUntilChanged()
        
        let repos = BehaviorRelay(value: [Repo]())
        self.repos = repos
        
        results = triggerRefresh.startWith(())
            .flatMapLatest {
                provider.rx.request(.trendingReposSinceLastWeek(q: "created:>" + Date().lastWeek(),
                                                                sort: "stars",
                                                                order: "desc"))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .trackActivity(activityIndicator)
            }
            .mapJSON()
            .mapToRepos()
            .do(onNext: {
                repos.accept($0)
            })
            .mapToRepoCellViewModels()
            .catchErrorJustReturn([])
            .do(onNext: {  viewModels in
                noResultFoundSubject.accept(viewModels.isEmpty)
            })
            .asDriver(onErrorJustReturn: [])
        
        selectedViewModel = selectedItem
            .asDriver(onErrorJustReturn: IndexPath())
            .map { indexPath in
                let repo = repos.value[indexPath.row]
                return RepositoryViewModel(provider: provider, repo: repo)
            }
    }
}

extension Observable {
    func mapToRepos() -> Observable<[Repo]> {
        return self.map { json in
            let dict = json as? [String: Any]
            if let items = dict?["items"] as? [Any] {
                return Repo.fromJSONArray(items)
            } else {
                return []
            }
        }
    }
}
