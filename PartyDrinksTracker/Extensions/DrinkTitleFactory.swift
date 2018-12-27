//
//  DrinksTitleFactory.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 27/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

class DrinkTitleFactory {
    public static func GetDrinkTitleFromSeque(sequeIdentifier: String!) -> Drink {
        switch sequeIdentifier {
        case "beerSeque":
            return Drink(type: DrinkType.Beer)
        default:
            return Drink(type: DrinkType.Shots)
        }
    }
}
