//
//  EntitiesFactory.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 25/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

class DrinksFactory {
    public static func CreateFrom(segueIdentifier: String!) -> Drink! {
        return Drink(type: GetDrinkTypeFrom(segueIdentifier: segueIdentifier))
    }
    
    public static func GetDrinkTitleFrom(segueIdentifier: String!, drinksCount: Int!) -> String! {
        let drinkType = GetDrinkTypeFrom(segueIdentifier: segueIdentifier)
        
        var title: String = ""
        
        switch drinkType {
            case DrinkType.Beer:
                title = "\(drinksCount ?? 0) "
                    + (drinksCount > 1 ? "beers" : "beer")
                    + " for today! Planning for more? :)"
            case DrinkType.Wine:
                title = "\(drinksCount ?? 0) "
                    + (drinksCount > 1 ? "glasses" : "glass")
                    + " of wine for today! Planning for more? :)"
            default:
                title = "\(drinksCount ?? 0) "
                    + (drinksCount > 1 ? "shots" : "shot")
                    + " for today! Planning for more? :)"
        }
        
        return title.uppercased()
    }
    
    public static func GetDrinkTypeFrom(segueIdentifier: String!) -> DrinkType {
        switch segueIdentifier {
        case "beerSegue":
            return DrinkType.Beer
        case "shotsSegue":
            return DrinkType.Shots
        default:
            return DrinkType.Wine
        }
    }
}
