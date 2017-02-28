import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIRefreshControl {
    
    public var isAnimating: ControlEvent<Void> {
        return controlEvent(.valueChanged)
    }
}
