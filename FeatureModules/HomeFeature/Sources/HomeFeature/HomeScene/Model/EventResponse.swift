//
//  Event.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 2.03.2025.
//

import Foundation


struct EventResponse: Codable {
    let id: String
    let sportKey: String
    let sportTitle: String?
    let commenceTime: String?
    let homeTeam: String?
    let awayTeam: String?
    let bookmakers: [Bookmaker]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case sportKey = "sport_key"
        case sportTitle = "sport_title"
        case commenceTime = "commence_time"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case bookmakers
    }
}
