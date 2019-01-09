//
//  DailyCigarretesViewModel.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 09/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

struct DailyCigarretesViewModel: Comparable {
    var cigarretesDate: Date
    var cigarretes: [Cigarrete]
    
    static func < (lhs: DailyCigarretesViewModel, rhs: DailyCigarretesViewModel) -> Bool {
        return lhs.cigarretesDate < rhs.cigarretesDate
    }
    
    static func == (lhs: DailyCigarretesViewModel, rhs: DailyCigarretesViewModel) -> Bool {
        return lhs.cigarretesDate == rhs.cigarretesDate
    }
}
