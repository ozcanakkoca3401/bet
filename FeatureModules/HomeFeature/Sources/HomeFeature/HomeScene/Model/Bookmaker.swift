//
//  Bookmaker.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 6.03.2025.
//

import Foundation

struct Bookmaker: Codable {
    let key: String
    let title: String
    let markets: [Market]
}
