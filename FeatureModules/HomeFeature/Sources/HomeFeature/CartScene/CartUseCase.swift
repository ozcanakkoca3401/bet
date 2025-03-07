//
//  CartUseCase.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 7.03.2025.
//

import Foundation
import RxSwift
import RxCocoa
import CoreNetwork

protocol CartUseCaseProtocol {
    func loadItems() -> [BetItemViewPresentation]
    func deleteItem(at index: Int)
    func calculateTotalAmount(price: Double) -> Double
}

final class CartUseCase: CartUseCaseProtocol {
    func loadItems() -> [BetItemViewPresentation] {
        return ManagerFactory.makeSelectionManager().getSelectedItems()
    }
    
    func deleteItem(at index: Int) {
        ManagerFactory.makeSelectionManager().deleteItem(at: index)
    }
    
    func calculateTotalAmount(price: Double) -> Double {
        let totalOdds = ManagerFactory.makeSelectionManager().getSelectedItems()
            .compactMap({ Double($0.odd)})
            .reduce(0, +)
        return (totalOdds * price).rounded(toPlaces: 5)
    }
}

