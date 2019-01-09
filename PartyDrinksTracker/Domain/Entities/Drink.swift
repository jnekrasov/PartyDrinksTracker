//
//  Drink.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 24/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

class Drink: Auditable {
    private(set) var type: DrinkType!
    var price: Decimal!
    var capacity: DrinkCapacity!
    
    init(type: DrinkType!) {
        self.type = type
    }
}
