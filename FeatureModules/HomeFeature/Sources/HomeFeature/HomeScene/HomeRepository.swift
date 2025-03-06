//
//  HomeRepository.swift
//  HomeModule
//
//  Created by Özcan AKKOCA on 28.01.2025.
//

import Foundation
import RxSwift
import CoreNetwork
import RxMoya

protocol HomeRepositoryProtocol {
    func getSports() -> Observable<[Sport]>
    func getOdds(for sportKey: String) -> Observable<[EventResponse]>
}

final class HomeRepository: HomeRepositoryProtocol {
    func getSports() -> Observable<[Sport]> {
        return provider.rx
            .request(.sports)
            .observe(on: MainScheduler.instance)
            .map([Sport].self)
            .asObservable()
    }
    
    func getOdds(for sportKey: String) -> Observable<[EventResponse]> {
        return provider.rx
            .request(.odds(sportKey: sportKey))
            .observe(on: MainScheduler.instance)
            .map([EventResponse].self)
            .asObservable()
    }
}
