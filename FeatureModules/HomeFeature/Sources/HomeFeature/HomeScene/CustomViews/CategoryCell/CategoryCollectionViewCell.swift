//
//  CategoryCollectionViewCell.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 3.03.2025.
//

import UIKit

final class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}

// Mark: - Setup
extension CategoryCollectionViewCell {
    func setupUI() {
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
    }
}
