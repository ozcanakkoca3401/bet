//
//  MockHomeRepository.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 2.02.2025.
//

import XCTest
import RxSwift
@testable import HomeFeature

final class MockHomeRepository: HomeRepositoryProtocol {
    var getSportsResult: Result<[Sport], Error> = .success([])
    var getOddsResult: Result<[EventResponse], Error> = .success([])

    func getSports() -> Observable<[Sport]> {
        return Observable.create { observer in
            switch self.getSportsResult {
            case .success(let sports):
                observer.onNext(sports)
                observer.onCompleted()
            case .failure(let error):
                observer.onError(error)
            }
            return Disposables.create()
        }
    }

    func getOdds(for sportKey: String) -> Observable<[EventResponse]> {
        return Observable.create { observer in
            switch self.getOddsResult {
            case .success(let odds):
                observer.onNext(odds)
                observer.onCompleted()
            case .failure(let error):
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
}
