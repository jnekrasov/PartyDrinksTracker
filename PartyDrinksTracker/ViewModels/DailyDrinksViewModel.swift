//
//  DailyDrinksViewModel.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 06/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

struct DailyDrinksViewModel: Comparable {
    var drinksDate: Date
    var drinks: [Drink]
    
    static func < (lhs: DailyDrinksViewModel, rhs: DailyDrinksViewModel) -> Bool {
        return lhs.drinksDate < rhs.drinksDate
    }
    
    static func == (lhs: DailyDrinksViewModel, rhs: DailyDrinksViewModel) -> Bool {
        return lhs.drinksDate == rhs.drinksDate
    }
}
