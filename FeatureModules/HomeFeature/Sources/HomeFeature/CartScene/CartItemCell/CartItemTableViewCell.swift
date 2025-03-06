//
//  CartItemTableViewCell.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 5.03.2025.
//

import UIKit
import CoreResource

protocol CartItemTableViewCellDelegate: AnyObject {
    func deleteItemFromCart(_ cell: CartItemTableViewCell)
}

final class CartItemTableViewCell: UITableViewCell {
    
    // MARK: - Views
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [teamLabel, oddLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    private let teamLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.regular(14, weight: .regular)
        return label
    }()
    
    private let oddLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.regular(14, weight: .medium)
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .red
        return button
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = CoreColors.gray7
        return view
    }()

    // MARK: - Properties
    weak var delegate: CartItemTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare(with presentation: BetItemViewPresentation) {
        teamLabel.text = "Takım: \(presentation.teamsName)"
        oddLabel.text = "Oran: " + presentation.odd
    }
}

private extension CartItemTableViewCell {
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubviewAndMakeConstraints(containerView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(deleteButton)
        contentView.addSubview(lineView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.lessThanOrEqualTo(deleteButton.snp.leading).offset(-8)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.size.equalTo(24)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
    }
    
    func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
}
    
// MARK: - Actions
private extension CartItemTableViewCell {
    @objc private func deleteButtonTapped() {
        delegate?.deleteItemFromCart(self)
    }
}


