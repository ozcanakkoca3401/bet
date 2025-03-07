//
//  HomeViewModel.swift
//  HomeModule
//
//  Created by Özcan AKKOCA on 28.01.2025.
//
//

import Foundation
import CoreNetwork
import CoreResource
import RxCocoa
import RxSwift

protocol HomeViewModelProtocol: AnyObject {
    // Add your custom methods here
    func loadData()
    var categoryItemPresentations: BehaviorRelay<[CategoryCollectionViewCellPresentation]> { get }
    var oddsItemPresentations: BehaviorRelay<[BetTableViewCellPresentation]> { get }
    var searchQuery: BehaviorRelay<String> { get }
    var filteredItems: Observable<[BetTableViewCellPresentation]> { get }
    var basketTapped: PublishSubject<Void> { get }
    var showEmptyBasketAlert: PublishSubject<Void> { get }

    var isLoading: BehaviorRelay<Bool> { get }
    var error: PublishSubject<String?> { get }
    func selectCategory(at index: Int)
    func selectOdd(at index: Int, itemIndex: Int)
    func pushOddDetail(at index: Int)
    
    var selectedItemsCount: BehaviorRelay<String> { get }
    var totalOddsRatio: BehaviorRelay<String> { get }
}

final class HomeViewModel {
    
    var categoryItemPresentations = BehaviorRelay<[CategoryCollectionViewCellPresentation]>(value: [])
    var oddsItemPresentations = BehaviorRelay<[BetTableViewCellPresentation]>(value: [])
    let searchQuery = BehaviorRelay<String>(value: .emptyValue)
    let basketTapped = PublishSubject<Void>()
    let showEmptyBasketAlert = PublishSubject<Void>()

    var filteredItems: Observable<[BetTableViewCellPresentation]> {
        return Observable.combineLatest(oddsItemPresentations.asObservable(), searchQuery.asObservable())
            .map { items, query in
                if query.isEmpty {
                    return items
                } else {
                    return items.filter { $0.teamsName.lowercased().contains(query.lowercased()) }
                }
            }
    }
    
    var isLoading = BehaviorRelay<Bool>(value: false)
    var error = PublishSubject<String?>()

    let selectedItemsCount = BehaviorRelay<String>(value: "0 \(CoreLocalize.Home.Match)")
    let totalOddsRatio = BehaviorRelay<String>(value: "1.00")

    private var sportResponse: [Sport] = .emptyValue

    private let router: HomeRouterProtocol
    private let service: HomeRepositoryProtocol
    private let disposeBag: DisposeBag
    private let calculateOddsUseCase: CalculateOddsUseCaseProtocol
    
    init(router: HomeRouterProtocol,
         service: HomeRepositoryProtocol,
         calculateOddsUseCase: CalculateOddsUseCaseProtocol = CalculateOddsUseCase(),
         disposeBag: DisposeBag = DisposeBag()) {
        self.router = router
        self.service = service
        self.calculateOddsUseCase = calculateOddsUseCase
        self.disposeBag = disposeBag
        addObservers()
    }
}

// MARK: - HomeViewModelProtocol
extension HomeViewModel: HomeViewModelProtocol {
 
    func loadData() {
        isLoading.accept(true)
        
        service.getSports()
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.isLoading.accept(false)
                self.error.onNext(nil)
                self.sportResponse = response
                
                self.categoryItemPresentations.accept(response.enumerated().map { index, sport in
                    CategoryCollectionViewCellPresentation(title: sport.title, isSelected: index == 0)
                })
                
                if let firstSport = response.first {
                    self.getOdds(for: firstSport.key)
                }
            }, onError: { [weak self] (error) in
                self?.isLoading.accept(false)
                self?.error.onNext(error.localizedDescription)
                print(error)
            }).disposed(by: disposeBag)
    }
    
    func selectCategory(at index: Int) {
        var currentItems = categoryItemPresentations.value
        for i in 0..<currentItems.count {
            currentItems[i] = CategoryCollectionViewCellPresentation(
                title: currentItems[i].title,
                isSelected: i == index
            )
        }
        categoryItemPresentations.accept(currentItems)
        getOdds(for: sportResponse[index].key)
    }
    
    func selectOdd(at index: Int, itemIndex: Int) {
        var currentItems = oddsItemPresentations.value
        let currentState = currentItems[index].items[itemIndex].isSelected
        
        if !currentState {
            for j in 0..<currentItems[index].items.count {
                currentItems[index].items[j].isSelected = false
            }
            currentItems[index].items[itemIndex].isSelected = true
        } else {
            currentItems[index].items[itemIndex].isSelected = false
        }
        
        currentItems[index].isSelectedDetailButton = false
        
        _ = ManagerFactory.makeSelectionManager().toggleSelection(item: currentItems[index].items[itemIndex], isDetailPage: false)
        ManagerFactory.makeAnalyticsManager().logEvent(name: AnalyticsManager.EventName.addToCart, params: nil)

        oddsItemPresentations.accept(currentItems)
        calculateSelectedItems()
    }

    func pushOddDetail(at index: Int) {
        guard let currentItem = oddsItemPresentations.value[index].items.first, let sportKey = currentItem.sportKey else { return }
        router.pushOddDetail(initialData: .init(id: currentItem.id, sportKey: sportKey))
    }
    
}

// MARK: - Methods
private extension HomeViewModel {
    func getOdds(for sportKey: String) {
        isLoading.accept(true)
        
        service.getOdds(for: sportKey)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                self.isLoading.accept(false)
                self.error.onNext(nil)
                print(response)
                
                self.oddsItemPresentations.accept(response.map { BetTableViewCellPresentation(with: $0) })
            }, onError: { [weak self] (error) in
                self?.isLoading.accept(false)
                self?.error.onNext(error.localizedDescription)
                print(error)
            }).disposed(by: disposeBag)
    }
    
    func addObservers() {
        ManagerFactory.makeSelectionManager().oddSelectionSubject
            .subscribe(onNext: { [weak self] selectedItem in
                guard let self = self else { return }
                var currentItems = self.oddsItemPresentations.value
                
                if let presentationIndex = currentItems.firstIndex(where: { presentation in
                    presentation.items.contains { item in
                        item.id == selectedItem.id
                    }
                }) {
                    // Update items in the found presentation
                    for j in 0..<currentItems[presentationIndex].items.count {
                        let item = currentItems[presentationIndex].items[j]
                        let isMatch = item.id == selectedItem.id &&
                        item.key == selectedItem.key &&
                        item.subKey == selectedItem.subKey &&
                        item.odd == selectedItem.odd
                        
                        currentItems[presentationIndex].items[j].isSelected = isMatch ? selectedItem.isSelected : false
                    }
                    
                    // Update detail button state
                    currentItems[presentationIndex].isSelectedDetailButton = ManagerFactory.makeSelectionManager().hasSelection(for: selectedItem.id) &&
                    !currentItems[presentationIndex].items.contains(where: { $0.isSelected })
                }
                
                self.oddsItemPresentations.accept(currentItems)
                
                self.calculateSelectedItems()

            })
            .disposed(by: disposeBag)
        

        
        basketTapped
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if ManagerFactory.makeSelectionManager().getSelectedItems().isEmpty {
                    self.showEmptyBasketAlert.onNext(())
                } else {
                    self.router.presentCartScreen()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func calculateSelectedItems() {
        self.selectedItemsCount.accept(calculateOddsUseCase.calculateSelectedItemsCount())
        self.totalOddsRatio.accept(calculateOddsUseCase.calculateTotalOddsRatio())
    }
}
