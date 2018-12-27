//
//  EntitiesFactory.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 25/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

class DrinksFactory {
    public static func CreateFromSeque(sequeIdentifier: String!) -> Drink {
        switch sequeIdentifier {
        case "beerSeque":
            return Drink(type: DrinkType.Beer)
        default:
            return Drink(type: DrinkType.Shots)
        }
    }
}
