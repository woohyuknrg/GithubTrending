import UIKit
import Moya
import RxSwift
import RxCocoa

class DiscoverViewController: UIViewController {
    
    var viewModel: DiscoverViewModel?
    
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var noResultsView: UIView!
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureRefreshControl()
        bindToRx()
    }
    
    func bindToRx() {
        guard let vm = viewModel else { return }
        
        title = vm.title
        tabBarItem.title = vm.title
        
        tableView.rx.itemSelected
            .bind(to: vm.selectedItem)
            .disposed(by: disposeBag)
        
        vm.results.drive(tableView.rx.items) {
            (tv: UITableView, index, rowViewModel: RepoCellViewModel) in
                let indexPath = IndexPath(item: index, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: String(describing: RepoCell.self), for: indexPath) as! RepoCell
                cell.configure(rowViewModel.fullName, description: rowViewModel.description, language: rowViewModel.language, stars: rowViewModel.stars)
                return cell
            }
            .disposed(by: disposeBag)
        
        vm.executing
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        vm.executing
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        vm.noResultsFound
            .map { !$0 }
            .drive(noResultsView.rx.isHidden)
            .disposed(by: disposeBag)
        
        vm.selectedViewModel
            .drive(onNext: { [weak self] repoViewModel in
                let repositoryViewController = UIStoryboard.main.repositoryViewController
                repositoryViewController.viewModel = repoViewModel
                self?.show(repositoryViewController, sender: nil)
            })
            .disposed(by: disposeBag)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        noResultsView.addGestureRecognizer(tapGestureRecognizer)
        
        _ = Observable.of(refreshControl.rx.isAnimating.asObservable(), tapGestureRecognizer.rx.event.map { _ in () })
            .merge()
            .bind(to: vm.triggerRefresh)
            .disposed(by: disposeBag)
        
    }
    
    fileprivate func configureTableView() {
        tableView.register(UINib(nibName: String(describing: RepoCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: RepoCell.self))
        tableView.tableFooterView = UIView() // Removes separators in empty cells
        tableView.estimatedRowHeight = 100.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    fileprivate func configureRefreshControl() {
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.lightGray
        tableView.addSubview(refreshControl)
    }
}
