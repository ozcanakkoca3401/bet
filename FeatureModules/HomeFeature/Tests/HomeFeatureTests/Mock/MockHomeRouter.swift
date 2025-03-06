//
//  MockHomeRouter.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 2.02.2025.
//

import XCTest
@testable import HomeFeature

final class MockHomeRouter: HomeRouterProtocol {
    var pushOddDetailCalled = false
    var pushOddDetailInitialData: HomeFeature.DetailInitialData?
    var presentCartScreenCalled = false
    
    func pushOddDetail(initialData: HomeFeature.DetailInitialData) {
        pushOddDetailCalled = true
        pushOddDetailInitialData = initialData
    }
    
    func presentCartScreen() {
        presentCartScreenCalled = true
    }
    
    var pushDetailScreenCalled = false
    var pushDetailScreenInitialData: HomeFeature.DetailInitialData?

    func pushDetailScreen(initialData: HomeFeature.DetailInitialData) {
        pushDetailScreenCalled = true
        pushDetailScreenInitialData = initialData
    }
}
