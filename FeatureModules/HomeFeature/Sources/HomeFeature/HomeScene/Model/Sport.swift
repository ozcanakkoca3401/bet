//
//  Sport.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 1.02.2025.
//

struct Sport: Codable {
    let key: String
    let group: String
    let title: String
    let description: String
    let active: Bool
    let hasOutrights: Bool
    
    enum CodingKeys: String, CodingKey {
        case key, group, title, description, active
        case hasOutrights = "has_outrights"
    }
}
