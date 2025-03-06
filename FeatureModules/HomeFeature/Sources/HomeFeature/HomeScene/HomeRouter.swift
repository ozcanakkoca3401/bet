//
//  HomeRouter.swift
//  HomeModule
//
//  Created by Özcan AKKOCA on 28.01.2025.
//
//

import UIKit
import RxSwift

// MARK: - RoutingProtocol
protocol HomeRouterProtocol: AnyObject {
    func pushOddDetail(initialData: DetailInitialData)
    func presentCartScreen()
}

// MARK: - Router
public final class HomeRouter {
    
    private weak var moduleViewController: MVVMHomeViewController?

    public init () {}
}

extension HomeRouter {
    public func start()  -> MVVMHomeViewController {
        let viewController = initModule()
        self.moduleViewController = viewController
        return viewController
    }
    
    private func initModule() -> MVVMHomeViewController {
        let viewController = MVVMHomeViewController()
        let viewModel = HomeViewModel(router: self, service: HomeRepository())
        viewController.viewModel = viewModel
        viewController.disposeBag = DisposeBag()
        return viewController
    }
}

// MARK: - HomeRouterProtocol
extension HomeRouter: HomeRouterProtocol {
    func pushOddDetail(initialData: DetailInitialData) {
        let vc = DetailRouter(initialData: initialData).start()
        moduleViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentCartScreen() {
        let vc = CartRouter().start()
        moduleViewController?.present(vc, animated: true)
    }
}
