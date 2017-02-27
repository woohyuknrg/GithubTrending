import UIKit
import Moya
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    var viewModel: LoginViewModel!
    
    @IBOutlet weak fileprivate var usernameTextField: UITextField!
    @IBOutlet weak fileprivate var passwordTextField: UITextField!
    @IBOutlet weak fileprivate var signInButton: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        customizeSignInButton()
    }
    
    func bindToRx() {
        _ = usernameTextField.rx.text.orEmpty.bindTo(viewModel.username).addDisposableTo(disposeBag)
        _ = passwordTextField.rx.text.orEmpty.bindTo(viewModel.password).addDisposableTo(disposeBag)
        _ = signInButton.rx.tap.bindTo(viewModel.loginTaps).addDisposableTo(disposeBag)
        
        viewModel.loginEnabled
            .drive(signInButton.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel.loginExecuting
            .drive(onNext: { executing in
                UIApplication.shared.isNetworkActivityIndicatorVisible = executing
            })
            .addDisposableTo(disposeBag)
        
        viewModel.loginFinished
            .drive(onNext: { [weak self] loginResult in
            switch loginResult {
                case .failed(let message):
                    let alert = UIAlertController(title: "Oops!", message:message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                    self?.present(alert, animated: true, completion: nil)
                case .ok:
                    self?.dismiss(animated: true, completion: nil)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: UI stuff
extension LoginViewController {
    fileprivate func customizeSignInButton() {
        signInButton.layer.cornerRadius = 6.0
        signInButton.layer.masksToBounds = true
    }
}
