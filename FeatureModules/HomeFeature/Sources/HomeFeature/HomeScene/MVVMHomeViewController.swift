//
//  MVVMHomeViewController.swift
//  HomeModule
//
//  Created by Özcan AKKOCA on 28.01.2025.
//
//

import UIKit
import SnapKit
import CoreResource
import CoreExtension
import SVProgressHUD
import RxSwift
import RxCocoa

public final class MVVMHomeViewController: UIViewController {
    
    // MARK: - Views
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = CoreLocalize.Home.Search
        return searchBar
    }()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: CategoryCollectionViewCell.className, bundle: Bundle.module), forCellWithReuseIdentifier: CategoryCollectionViewCell.className)
        return collectionView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: BetTableViewCell.className, bundle: Bundle.module),
                         forCellReuseIdentifier: BetTableViewCell.className)

        return tableView
    }()
    
    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        let lineView = UIView()
        lineView.backgroundColor = .gray
        view.addSubview(lineView)
        
        lineView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        return view
    }()
    
    private let basketView: UIView = {
        let view = UIView()
        view.backgroundColor = CoreColors.darkGreen
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let selectedItemsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let oddsRatioLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Properties
    var viewModel: HomeViewModelProtocol!
    var disposeBag: DisposeBag!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadData()
    }
}

// MARK: - Binding
private extension MVVMHomeViewController {
    func setupBindings() {
        
        // Bind loading state
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { isLoading in
                isLoading ? SVProgressHUD.show() : SVProgressHUD.dismiss()
            })
            .disposed(by: disposeBag)
        
        // Bind searchBar
        searchBar.rx.text.orEmpty
                    .bind(to: viewModel.searchQuery)
                    .disposed(by: disposeBag)
        
        // Bind collection items
        viewModel
            .categoryItemPresentations
            .bind(to: categoryCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.className, cellType: CategoryCollectionViewCell.self)) { (index, element, cell) in
                cell.titleLabel.text = element.title
                cell.containerView.backgroundColor = element.isSelected ? CoreColors.darkGreen : CoreColors.green
            }
            .disposed(by: disposeBag)

        
        // Handle collection view item selection
        categoryCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.selectCategory(at: indexPath.row)
            })
            .disposed(by: disposeBag)

        
        // Bind table items
        viewModel
            .filteredItems
            .bind(to: tableView.rx.items(cellIdentifier: BetTableViewCell.className, cellType: BetTableViewCell.self)) { [weak self] (index, element, cell) in
                cell.prepare(with: element)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        // Basket binding
        let basketTapGesture = UITapGestureRecognizer()
        basketView.addGestureRecognizer(basketTapGesture)
        
        basketTapGesture.rx.event
            .map { _ in }
            .bind(to: viewModel.basketTapped)
            .disposed(by: disposeBag)
        
        viewModel.showEmptyBasketAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let alert = UIAlertController(
                    title: CoreLocalize.General.Warning,
                    message: CoreLocalize.General.EmptyCart,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: CoreLocalize.General.OkButton, style: .default))
                self?.present(alert, animated: true)
            })
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
        
        viewModel.selectedItemsCount
            .bind(to: selectedItemsLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.totalOddsRatio
            .bind(to: oddsRatioLabel.rx.text)
            .disposed(by: disposeBag)
    }
}


// MARK: - UI
private extension MVVMHomeViewController {
    func setupUI() {
        title = CoreLocalize.Home.Title
        view.backgroundColor = CoreColors.white7
        
        view.addSubview(searchBar)
        view.addSubview(categoryCollectionView)
        view.addSubview(tableView)
        view.addSubview(bottomView)
        
        bottomView.addSubview(basketView)
        
        basketView.addSubview(selectedItemsLabel)
        basketView.addSubview(oddsRatioLabel)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        basketView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(80)
        }
        
        selectedItemsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }
        
        oddsRatioLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - UI
extension MVVMHomeViewController: BetTableViewCellDelegate {
    func didSelectBetTableViewCell(_ cell: BetTableViewCell, oddIndex: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.selectOdd(at: indexPath.row, itemIndex: oddIndex)
    }
    
    func didSelectDetailBetTableViewCell(_ cell: BetTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.pushOddDetail(at: indexPath.row)

    }
}
