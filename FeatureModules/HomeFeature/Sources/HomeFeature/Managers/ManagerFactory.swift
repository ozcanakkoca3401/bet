//
//  ManagerFactory.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 6.03.2025.
//

import Foundation
import UIKit
import CoreNetwork

protocol ManagerFactoring {
    static func makeSelectionManager() -> SelectionManaging
    static func makeAnalyticsManager() -> AnalyticsManaging
}

final class ManagerFactory: ManagerFactoring {
    
    static var shared: ManagerFactory = ManagerFactory()
    
    static func makeSelectionManager() -> SelectionManaging {
        return SelectionManager.shared
    }
    
    static func makeAnalyticsManager() -> AnalyticsManaging {
        return AnalyticsManager.shared
    }
}
