//
//  MoyaProvider.swift
//  CoreNetwork
//
//  Created by Özcan AKKOCA on 2.03.2025.
//

import Foundation
import Moya
import RxSwift

public let provider: MoyaProvider<AppAPI> = {
    return MoyaProvider<AppAPI>.init(plugins: [NetworkLoggerPlugin()])
}()

public enum AppAPI {
    case sports
    case odds(sportKey: String)
    case events(id: String, sportKey: String)
}

fileprivate let apiKey = "63f2c8d5321ddcd9e077b27a989b7e7b"

extension AppAPI: TargetType {
    public var baseURL: URL {
        return URL(string: Endpoint.production.rawValue)!
    }
    
    public var path: String {
        switch self {
        case .sports:
            return "/sports"
        case .odds(let sportKey):
            return "/sports/\(sportKey)/odds"
        case .events(let id, let sportKey):
            return "/sports/\(sportKey)/events/\(id)/odds"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        switch self {
        case .sports:
            return .requestParameters(
                parameters: ["apiKey": apiKey],
                encoding: URLEncoding.queryString
            )
            
        case .odds:
            return .requestParameters(
                parameters: [
                    "apiKey": apiKey,
                    "regions": "eu",
                    "markets": "h2h",
                    "dateFormat": "iso",
                    "oddsFormat": "decimal"
                ],
                encoding: URLEncoding.queryString
            )
        case .events:
            return .requestParameters(
                parameters: [
                    "apiKey": apiKey,
                    "regions": "eu",
                    "markets": "h2h",
                    "dateFormat": "iso",
                    "oddsFormat": "decimal"
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    
    public var headers: [String: String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    public var sampleData: Data {
        return Data()
    }
}

