//
//  DetailRouter.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 2.02.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//
//

import UIKit
import RxSwift

// MARK: - RoutingProtocol
protocol DetailRouterProtocol: AnyObject {
}

// MARK: - Router
final class DetailRouter {
    private weak var moduleViewController: MVVMDetailViewController?
    private let initialData: DetailInitialData
    
    init(initialData: DetailInitialData) {
        self.initialData = initialData
    }
}

extension DetailRouter {
    func start() -> MVVMDetailViewController {
        let viewController = initModule()
        self.moduleViewController = viewController
        return viewController
    }
    
    private func initModule() -> MVVMDetailViewController {
        let viewController = MVVMDetailViewController()
        let viewModel = DetailViewModel(router: self,
                                        service: DetailRepository(),
                                        initialData: initialData)
        viewController.viewModel = viewModel
        viewController.disposeBag = DisposeBag()
        return viewController
    }
}

// MARK: - DetailRouterProtocol
extension DetailRouter: DetailRouterProtocol {
}
