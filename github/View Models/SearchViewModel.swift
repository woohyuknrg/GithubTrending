import Foundation
import RxSwift
import RxCocoa
import Moya

enum SearchViewModelResult {
    case query([RepoCellViewModel])
    case queryNothingFound
    case empty
}

class SearchViewModel {

    // Input
    var searchText = BehaviorRelay(value: "")
    var selectedItem = PublishSubject<IndexPath>()
    
    // Output
    let results: Driver<SearchViewModelResult>
    let executing: Driver<Bool>
    let selectedViewModel: Observable<RepositoryViewModel>
    let title = "Search"
    
    fileprivate let repoModels: BehaviorRelay<[Repo]>
    fileprivate let provider: MoyaProvider<GitHub>
    
    init(provider: MoyaProvider<GitHub>) {
        self.provider = provider
        
        let activityIndicator = ActivityIndicator()
        self.executing = activityIndicator.asDriver().distinctUntilChanged()
        
        let repoModels = BehaviorRelay(value: [Repo]())
        self.repoModels = repoModels
        
        let searchTextObservable = searchText.asObservable()
        
        let queryResultsObservable = searchTextObservable
            .throttle(0.3, scheduler: MainScheduler.instance)
            .filter { $0.count > 0 }
            .flatMapLatest { query in
                provider.rx.request(GitHub.repoSearch(q: query.URLEscapedString))
                    .retry(3)
                    .trackActivity(activityIndicator)
                    .observeOn(MainScheduler.instance)
            }
            .mapToModels(Repo.self, arrayRootKey: "items")
            .do(onNext: { models in
                repoModels.accept(models)
            })
            .mapToRepoCellViewModels()
            .map { viewModels -> SearchViewModelResult in
                viewModels.isEmpty ? .queryNothingFound : .query(viewModels)
            }
            .asDriver(onErrorJustReturn: .queryNothingFound)
        
         let noResultsObservable = searchTextObservable
            .filter { $0.count == 0 }
            .map { _ -> SearchViewModelResult in
                .empty
            }
            .asDriver(onErrorJustReturn: .empty)
        
        results = Driver.of(queryResultsObservable, noResultsObservable).merge()
        
        selectedViewModel = selectedItem
            .withLatestFrom(repoModels.asObservable()) { indexPath, models in
                models[indexPath.row]
            }
            .map { model in
                RepositoryViewModel(provider: provider, repo: model)
            }
            .share(replay: 1)
    }
}
