//
//  CartRouter.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 5.03.2025.
//

import UIKit
import RxSwift

// MARK: - RoutingProtocol
protocol CartRouterProtocol: AnyObject {
    func dismiss()
}

// MARK: - Router
final class CartRouter {
    private weak var moduleViewController: UINavigationController?

    init() {}
}

extension CartRouter {
    func start() -> UINavigationController {
        let viewController = UINavigationController(rootViewController: initModule())
        self.moduleViewController = viewController
        return viewController
    }
    
    private func initModule() -> MVVMCartViewController {
        let viewController = MVVMCartViewController()
        let viewModel = CartViewModel(router: self)
        viewController.viewModel = viewModel
        viewController.disposeBag = DisposeBag()
        return viewController
    }
}

// MARK: - CartRouterProtocol
extension CartRouter: CartRouterProtocol {
    func dismiss() {
        moduleViewController?.dismiss(animated: true, completion: nil)
    }
}
