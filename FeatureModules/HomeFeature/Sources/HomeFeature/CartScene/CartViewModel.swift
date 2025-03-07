//
//  CartViewModel.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 5.03.2025.
//

import Foundation
import CoreNetwork
import RxCocoa
import RxSwift

protocol CartViewModelProtocol: AnyObject {
    func loadData()
    func deleteItem(at index: Int)
    func updatePrice(_ price: String)
    
    var title: PublishSubject<String> { get }
    var oddsItemPresentations: BehaviorRelay<[BetItemViewPresentation]> { get }
    var isLoading: BehaviorRelay<Bool> { get }
    var error: PublishSubject<String?> { get }
    var totalAmount: BehaviorRelay<Double> { get }
    var price: BehaviorRelay<String> { get }
}

final class CartViewModel {

    var title: PublishSubject<String> = PublishSubject<String>()
    var oddsItemPresentations = BehaviorRelay<[BetItemViewPresentation]>(value: [])
    var isLoading = BehaviorRelay<Bool>(value: false)
    var error = PublishSubject<String?>()
    var totalAmount = BehaviorRelay<Double>(value: 0.0)
    var price = BehaviorRelay<String>(value: "30")
    
    private let router: CartRouterProtocol
    private let disposeBag: DisposeBag
    private let useCase: CartUseCaseProtocol
    
    init(router: CartRouter,
         useCase: CartUseCaseProtocol = CartUseCase(),
         disposeBag: DisposeBag = DisposeBag()) {
        self.router = router
        self.useCase = useCase
        self.disposeBag = disposeBag
    }
    

}

// MARK: - CartViewModelProtocol
extension CartViewModel: CartViewModelProtocol {
    func loadData() {
        let items = useCase.loadItems()
        oddsItemPresentations.accept(items)
        if items.isEmpty {
            router.dismiss()
        } else {
            calculateTotalAmount()
        }

    }
    
    func deleteItem(at index: Int) {
        useCase.deleteItem(at: index)
        ManagerFactory.makeAnalyticsManager().logEvent(name: AnalyticsManager.EventName.removeFromCart, params: nil)
        loadData()
    }
    
    func updatePrice(_ price: String) {
        guard let numericPrice = Double(price),
              numericPrice > 0,
              numericPrice <= 5000 else { return }
        
        self.price.accept(price)
        calculateTotalAmount()
    }
}

// MARK: - Methods
private extension CartViewModel {
    func calculateTotalAmount() {
        let currentPrice = Double(price.value) ?? 30
        let calculatedAmount = useCase.calculateTotalAmount(price: currentPrice)
        totalAmount.accept(calculatedAmount)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
