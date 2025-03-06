//
//  MVVMDetailViewController.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 2.02.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//
//

import UIKit
import SnapKit
import CoreResource
import CoreExtension
import SVProgressHUD
import RxSwift
import RxCocoa

final class MVVMDetailViewController: UIViewController {
    
    // MARK: - Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.register(UINib(nibName: BetTableViewCell.className, bundle: Bundle.module),
                           forCellReuseIdentifier: BetTableViewCell.className)
        
        return tableView
    }()
    
    // MARK: - Properties
    var viewModel: DetailViewModelProtocol!
    var disposeBag: DisposeBag!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadData()
        viewModel.sendAnalyticsEvent()
    }
}

// MARK: - Binding
private extension MVVMDetailViewController {
    func setupBindings() {
        
        // Bind loading state
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isLoading in
                isLoading ? SVProgressHUD.show() : SVProgressHUD.dismiss()
            })
            .disposed(by: disposeBag)
        
        // Bind navigation title
        viewModel.title
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        // Bind table items
        viewModel
            .oddsItemPresentations
            .bind(to: tableView.rx.items(cellIdentifier: BetTableViewCell.className, cellType: BetTableViewCell.self)) { [weak self] (index, element, cell) in
                cell.prepare(with: element)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        // Add error binding
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { errorMessage in
                if let message = errorMessage {
                    SVProgressHUD.showError(withStatus: message)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
private extension MVVMDetailViewController {
    func setupUI() {
        view.backgroundColor = CoreColors.white7
        view.addSubviewAndMakeConstraints(tableView)
    }
}

// MARK: - DetailViewDelegate
extension MVVMDetailViewController: BetTableViewCellDelegate {
    func didSelectBetTableViewCell(_ cell: BetTableViewCell, oddIndex: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.selectOdd(at: indexPath.row, itemIndex: oddIndex)
    }
}
