//
//  MVVMCartViewController.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 5.03.2025.
//

import UIKit
import SnapKit
import CoreResource
import CoreExtension
import SVProgressHUD
import RxSwift
import RxCocoa

final class MVVMCartViewController: UIViewController {
    
    // MARK: - Views
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.registerReusableCell(CartItemTableViewCell.self)
        return tableView
    }()
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var totalAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        return label
    }()

    private lazy var priceTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.placeholder = CoreLocalize.Cart.Price
        textField.text = "30"
        textField.font = .systemFont(ofSize: 14)
        return textField
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = CoreColors.green
        button.setTitle(CoreLocalize.Cart.Play, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Properties
    var viewModel: CartViewModelProtocol!
    var disposeBag: DisposeBag!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadData()
    }
}

// MARK: - Binding
private extension MVVMCartViewController {
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
            .bind(to: tableView.rx.items(cellIdentifier: CartItemTableViewCell.className, cellType: CartItemTableViewCell.self)) { (index, element, cell) in
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
        
        // Add total amount binding
        viewModel.totalAmount
            .observe(on: MainScheduler.instance)
            .map { "Toplam: ₺\($0)" }
            .bind(to: totalAmountLabel.rx.text)
            .disposed(by: disposeBag)
        
        priceTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] price in
                self?.viewModel.updatePrice(price)
            })
            .disposed(by: disposeBag)
        
        viewModel.price
            .bind(to: priceTextField.rx.text)
            .disposed(by: disposeBag)
        
        // Add play button action
        playButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let alert = UIAlertController(
                    title: CoreLocalize.Cart.Congratulations,
                    message: CoreLocalize.Cart.Created,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: CoreLocalize.General.OkButton, style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI
private extension MVVMCartViewController {
    func setupUI() {
        title = CoreLocalize.Cart.Title
        view.backgroundColor = CoreColors.white7
        
        view.addSubview(tableView)
        view.addSubview(bottomView)
        bottomView.addSubview(totalAmountLabel)
        bottomView.addSubview(playButton)
        bottomView.addSubview(priceTextField)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(100)
        }
        
        totalAmountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        }
        
        priceTextField.snp.makeConstraints { make in
            make.top.equalTo(totalAmountLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(80)
            make.height.equalTo(36)
        }
        
        // Update playButton constraints
        playButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(130)
        }
    }
}

// MARK: - UI
extension MVVMCartViewController: CartItemTableViewCellDelegate {
    func deleteItemFromCart(_ cell: CartItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.deleteItem(at: indexPath.row)
    }
}
