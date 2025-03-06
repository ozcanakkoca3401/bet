//
//  HomeFeatureTests.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 2.02.2025.
//

import XCTest
@testable import HomeFeature
import CoreNetwork
import CoreResource

final class HomeViewModelTests: XCTestCase {

    private var mockRouter: MockHomeRouter!
    private var mockRepository: MockHomeRepository!
    private var viewModel: HomeViewModel!

    override func setUp() {
        super.setUp()
        mockRouter = MockHomeRouter()
        mockRepository = MockHomeRepository()
        viewModel = HomeViewModel(router: mockRouter, service: mockRepository)
    }

    override func tearDown() {
        mockRouter = nil
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }


    // MARK: - Test Loading Data
    func testLoadData_Success() {
        // Given
        let sports = [
            Sport(key: "soccer", group: "Soccer", title: "Soccer", description: "Soccer games", active: true, hasOutrights: false),
            Sport(key: "basketball", group: "Basketball", title: "Basketball", description: "Basketball games", active: true, hasOutrights: false)
        ]
        mockRepository.getSportsResult = .success(sports)
        
        let expectation = XCTestExpectation(description: "Load data completion")
        
        // When
        viewModel.loadData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.categoryItemPresentations.value.count, 2)
            XCTAssertTrue(self.viewModel.categoryItemPresentations.value[0].isSelected)
            XCTAssertFalse(self.viewModel.categoryItemPresentations.value[1].isSelected)
            XCTAssertFalse(self.viewModel.isLoading.value)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadData_Error() {
        // Given
        let expectedError = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        mockRepository.getSportsResult = .failure(expectedError)
        
        let expectation = XCTestExpectation(description: "Load data error")
        
        // When
        viewModel.loadData()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading.value)
          //  XCTAssertEqual(self.viewModel.error.value ?? "", expectedError.localizedDescription)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSelectCategory() {
        // Given
        let sports = [
            Sport(key: "soccer", group: "Soccer", title: "Soccer", description: "Soccer games", active: true, hasOutrights: false),
            Sport(key: "basketball", group: "Basketball", title: "Basketball", description: "Basketball games", active: true, hasOutrights: false)
        ]
        mockRepository.getSportsResult = .success(sports)
        viewModel.loadData()
        
        // When
        viewModel.selectCategory(at: 1)
        
        // Then
        XCTAssertFalse(viewModel.categoryItemPresentations.value[0].isSelected)
        XCTAssertTrue(viewModel.categoryItemPresentations.value[1].isSelected)
    }
    
    func testPushOddDetail() {
        // Given
        let bet = BetTableViewCellPresentation(
            teamsName: "Team A vs Team B",
            items: [BetItemViewPresentation(id: "123", sportKey: "soccer", key: "key1", subKey: "subkey1", odd: "1.5", teamsName: "Team A vs Team B", isSelected: false)]
        )
        viewModel.oddsItemPresentations.accept([bet])
        
        // When
        viewModel.pushOddDetail(at: 0)
        
        // Then
        XCTAssertEqual(mockRouter.pushOddDetailInitialData?.id, "123")
        XCTAssertEqual(mockRouter.pushOddDetailInitialData?.sportKey, "soccer")
    }
}
