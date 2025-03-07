//
//  HomeRouter.swift
//  HomeModule
//
//  Created by Özcan AKKOCA on 28.01.2025.
//
//

import Foundation
import CoreResource

protocol CalculateOddsUseCaseProtocol {
    func calculateSelectedItemsCount() -> String
    func calculateTotalOddsRatio() -> String
}

final class CalculateOddsUseCase: CalculateOddsUseCaseProtocol {
    
    private let selectionManager: SelectionManaging
    
    init(selectionManager: SelectionManaging = ManagerFactory.makeSelectionManager()) {
        self.selectionManager = selectionManager
    }
    
    func calculateSelectedItemsCount() -> String {
        let items = selectionManager.getSelectedItems()
        return "\(items.count) \(CoreLocalize.Home.Match)"
    }
    
    func calculateTotalOddsRatio() -> String {
        let totalOdds = selectionManager.getSelectedItems().compactMap({ Double($0.odd)}).reduce(0, +)
        return String(format: "%.2f", totalOdds)
    }
}

