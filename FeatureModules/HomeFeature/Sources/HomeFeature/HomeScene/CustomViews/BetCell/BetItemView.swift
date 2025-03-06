//
//  BetItemView.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 3.03.2025.
//

import UIKit
import CoreResource

final class BetItemView: UIView {
    
    @IBOutlet weak var oddBackgroundView: UIView!
    @IBOutlet weak var oddLabel: UILabel!
    @IBOutlet weak var oddButton: UIButton!
    
    class func create() -> BetItemView {
        guard let view = UINib(nibName: BetItemView.className, bundle: Bundle.module).instantiate(withOwner: self, options: nil).first as? BetItemView else {
            return BetItemView()
        }
        
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        return view
    }

    func prepare(with presentation: BetItemViewPresentation) {
        oddLabel.text = presentation.odd
        oddBackgroundView.backgroundColor = presentation.isSelected ? CoreColors.darkGreen : CoreColors.green
        oddBackgroundView.layer.cornerRadius = 8
        oddBackgroundView.layer.masksToBounds = true
    }
    
}
