//
//  BetTableViewCellPresentation.swift
//  HomeFeature
//
//  Created by Özcan AKKOCA on 4.03.2025.
//

struct BetTableViewCellPresentation {
    let emptyText: String = "Maç verisi yok"
    let teamsName: String
    var items: [BetItemViewPresentation]
    var isHiddenDetailButton: Bool = false
    var isSelectedDetailButton: Bool = false
}

extension BetTableViewCellPresentation {
    init(with model: EventResponse) {
        teamsName = (model.homeTeam ?? .emptyValue) + " - " + (model.awayTeam ?? .emptyValue)
        
        if let bookmaker = model.bookmakers?.first, let market = bookmaker.markets.first {
            items = market.outcomes.map({ BetItemViewPresentation(id: model.id,
                                                                  sportKey: model.sportKey,
                                                                  key: bookmaker.key,
                                                                  subKey: market.key,
                                                                  odd: String(describing: $0.price), teamsName: (model.homeTeam ?? .emptyValue) + " - " + (model.awayTeam ?? .emptyValue),
                                                                  isSelected: ManagerFactory.makeSelectionManager().isSelected(id: model.id,
                                                                                                                 key: bookmaker.key,
                                                                                                                 subKey: market.key,
                                                                                                                 odd: String(describing: $0.price)))})
            
            if ManagerFactory.makeSelectionManager().hasSelection(for: model.id), !items.contains(where: { $0.isSelected }) {
                isSelectedDetailButton = true
            }

        } else {
            items = []
        }
    }
    
}
