//
//  DetailRepository.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 4.03.2025.
//

import Foundation
import RxSwift
import CoreNetwork
import RxMoya

protocol DetailRepositoryProtocol {
    func getEvents(for sportKey: String, id: String) -> Observable<EventResponse>
}

final class DetailRepository: DetailRepositoryProtocol {
    func getEvents(for sportKey: String, id: String) -> Observable<EventResponse> {
        return provider.rx
            .request(.events(id: id, sportKey: sportKey))
            .observe(on: MainScheduler.instance)
            .map(EventResponse.self)
            .asObservable()
    }
}
