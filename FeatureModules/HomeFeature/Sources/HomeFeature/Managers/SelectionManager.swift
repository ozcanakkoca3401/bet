//
//  SelectionManager.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 6.03.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol SelectionManaging: AnyObject {
    var oddSelectionSubject: PublishSubject<BetItemViewPresentation> { get }
    func isSelected(id: String, key: String, subKey: String, odd: String) -> Bool
    func hasSelection(for id: String) -> Bool
    func toggleSelection(item: BetItemViewPresentation, isDetailPage: Bool) -> Bool
    func getSelectedItems() -> [BetItemViewPresentation]
    func deleteItem(at index: Int)
}

final class SelectionManager: SelectionManaging {
    static let shared = SelectionManager()
    
    let oddSelectionSubject = PublishSubject<BetItemViewPresentation>()

    private init() {}
    
    private var selectedItems: [String: BetItemViewPresentation] = [:]
    
    func isSelected(id: String, key: String, subKey: String, odd: String) -> Bool {
        guard let item = selectedItems[id] else { return false }
        return item.key == key && item.subKey == subKey && item.odd == odd
    }
    
    func hasSelection(for id: String) -> Bool {
        return selectedItems[id] != nil
    }
    
    @discardableResult
    func toggleSelection(item: BetItemViewPresentation, isDetailPage: Bool = false) -> Bool {
        let compositeKey = item.id
        
        if let existingItem = selectedItems[compositeKey] {
            if existingItem.key == item.key &&
                existingItem.subKey == item.subKey &&
                existingItem.odd == item.odd {
                // If all properties match, remove the item
                selectedItems.removeValue(forKey: compositeKey)
                if isDetailPage {
                    oddSelectionSubject.onNext(item)
                }
                return false
            } else {
                // If properties are different, update with new item
                selectedItems[compositeKey] = item
                if isDetailPage {
                    oddSelectionSubject.onNext(item)
                }
                return true
            }
        } else {
            // No existing item, add new one
            selectedItems[compositeKey] = item
            if isDetailPage {
                oddSelectionSubject.onNext(item)
            }
            return true
        }
    }
    
    func getSelectedItems() -> [BetItemViewPresentation] {
        return Array(selectedItems.values)
    }
    
    func deleteItem(at index: Int) {
        let items = Array(selectedItems.values)
        guard index < items.count else { return }
        var item = items[index]
        item.isSelected = false
        _ = toggleSelection(item: item, isDetailPage: true)
    }
}
