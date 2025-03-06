//
//  DetailViewModel.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 2.02.2025.
//  Copyright (c) 2025 ___ORGANIZATIONNAME___. All rights reserved.
//
//

import Foundation
import CoreNetwork
import RxCocoa
import RxSwift

protocol DetailViewModelProtocol: AnyObject {
    func loadData()
    func selectOdd(at index: Int, itemIndex: Int)
    func sendAnalyticsEvent()
    
    var title: PublishSubject<String> { get }
    var oddsItemPresentations: BehaviorRelay<[BetTableViewCellPresentation]> { get }
    var isLoading: BehaviorRelay<Bool> { get }
    var error: PublishSubject<String?> { get }
}

final class DetailViewModel {

    var title: PublishSubject<String> = PublishSubject<String>()
    var oddsItemPresentations = BehaviorRelay<[BetTableViewCellPresentation]>(value: [])
    var isLoading = BehaviorRelay<Bool>(value: false)
    var error = PublishSubject<String?>()

    private let router: DetailRouterProtocol
    private let service: DetailRepositoryProtocol
    private let initialData: DetailInitialData
    private let disposeBag: DisposeBag
    
    init(router: DetailRouterProtocol,
         service: DetailRepositoryProtocol,
         initialData: DetailInitialData,
         disposeBag: DisposeBag = DisposeBag()) {
        self.router = router
        self.service = service
        self.initialData = initialData
        self.disposeBag = disposeBag
    }
}

// MARK: - DetailViewModelProtocol
extension DetailViewModel: DetailViewModelProtocol {
    func loadData() {
        isLoading.accept(true)
        
        service.getEvents(for: initialData.sportKey, id: initialData.id)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.isLoading.accept(false)
                self.error.onNext(nil)
                print(response)
                self.title.onNext("\(response.homeTeam ?? .emptyValue) - \(response.awayTeam ?? .emptyValue)")
                
                let betTableViewCellPresentations = (response.bookmakers ?? []).map { bookmaker in
                    let outcomePresentations = (bookmaker.markets.first?.outcomes ?? []).map { outcome in
                        BetItemViewPresentation(id: self.initialData.id,
                                                sportKey: nil,
                                                key: bookmaker.key,
                                                subKey: bookmaker.markets.first?.key ?? .emptyValue,
                                                odd: String(describing: outcome.price),
                                                teamsName: (response.homeTeam ?? .emptyValue) + " - " + (response.awayTeam ?? .emptyValue),
                                                isSelected: ManagerFactory.makeSelectionManager().isSelected(id: self.initialData.id,
                                                                                               key: bookmaker.key,
                                                                                               subKey: bookmaker.markets.first?.key ?? .emptyValue,
                                                                                               odd: String(describing: outcome.price)))
                    }
                    
                    return BetTableViewCellPresentation(teamsName: bookmaker.title, items: outcomePresentations, isHiddenDetailButton: true)
                }
                
                self.oddsItemPresentations.accept(betTableViewCellPresentations)
            }, onError: { [weak self] (error) in
                self?.isLoading.accept(false)
                self?.error.onNext(error.localizedDescription)
                print(error)
            }).disposed(by: disposeBag)
    }
    
    func selectOdd(at index: Int, itemIndex: Int) {
        var currentItems = oddsItemPresentations.value
        
        // Get current selection state of clicked item
        let currentState = currentItems[index].items[itemIndex].isSelected
        
        // Deselect all items in all cells first
        for i in 0..<currentItems.count {
            for j in 0..<currentItems[i].items.count {
                currentItems[i].items[j].isSelected = false
            }
        }
        
        // Only select the clicked item if it wasn't already selected
        if !currentState {
            currentItems[index].items[itemIndex].isSelected = true
        }
        
        _ = ManagerFactory.makeSelectionManager().toggleSelection(item: currentItems[index].items[itemIndex], isDetailPage: true)
        
        // Update the relay
        oddsItemPresentations.accept(currentItems)
        
        ManagerFactory.makeAnalyticsManager().logEvent(name: AnalyticsManager.EventName.addToCart, params: nil)
    }
    
    func sendAnalyticsEvent() {
        ManagerFactory.makeAnalyticsManager().logEvent(name: AnalyticsManager.EventName.matchDetail, params: nil)
    }
}

