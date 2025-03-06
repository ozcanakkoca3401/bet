//
//  BetTableViewCell.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 3.03.2025.
//

import UIKit
import RxSwift
import CoreResource

protocol BetTableViewCellDelegate: AnyObject {
    func didSelectBetTableViewCell(_ cell: BetTableViewCell, oddIndex: Int)
    func didSelectDetailBetTableViewCell(_ cell: BetTableViewCell)
}

extension BetTableViewCellDelegate {
    func didSelectDetailBetTableViewCell(_ cell: BetTableViewCell) { }
}

class BetTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var oddsStackView: UIStackView!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var detailButtonBackgroundView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    let disposeBag = DisposeBag()
    var cellIndex: Int?
    
    // Properties
    weak var delegate: BetTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        
        
        detailButton.backgroundColor = CoreColors.green
        detailButton.layer.cornerRadius = 8
        detailButton.layer.masksToBounds = true
        
        
        detailButton.rx.tap.bind{ [weak self] in
            guard let self = self else { return }
            self.delegate?.didSelectDetailBetTableViewCell(self)
        }.disposed(by: disposeBag)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        oddsStackView.removeAllArrangedSubviews()
    }
    
    func prepare(with presentation: BetTableViewCellPresentation) {
        emptyLabel.text = presentation.emptyText
        emptyLabel.isHidden = !presentation.items.isEmpty
        oddsStackView.isHidden = presentation.items.isEmpty
        detailButtonBackgroundView.isHidden = presentation.isHiddenDetailButton ? true : presentation.items.isEmpty
        detailButton.backgroundColor = presentation.isSelectedDetailButton ? CoreColors.darkGreen : CoreColors.green
        titleLabel.text = presentation.teamsName
        
        presentation.items.enumerated().forEach { index, presentation in
            let itemView = BetItemView.create()
            itemView.prepare(with: presentation)
            oddsStackView.addArrangedSubview(itemView)
            
            itemView.oddButton.rx.tap.bind { [weak self] in
                guard let self = self else { return }
                self.delegate?.didSelectBetTableViewCell(self, oddIndex: index)
            }.disposed(by: disposeBag)
        }
    }
    
}
