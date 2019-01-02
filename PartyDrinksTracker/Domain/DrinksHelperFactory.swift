//
//  EntitiesFactory.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 25/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

class DrinksHelperFactory {
    public static func GetDrinkTitleFrom(segueIdentifier: String!, drinksCount: Int!) -> String! {
        let drinkType = GetDrinkTypeFrom(segueIdentifier: segueIdentifier)
        
        var title: String = ""
        let count = drinksCount ?? 0
        
        switch drinkType {
            case DrinkType.Beer:
                title = "\(count) "
                    + (count > 1 ? "beers" : "beer")
                    + " for today! Planning for more? :)"
            case DrinkType.Wine:
                title = "\(count) "
                    + (count > 1 ? "glasses" : "glass")
                    + " of wine for today! Planning for more? :)"
            default:
                title = "\(count) "
                    + (count > 1 ? "shots" : "shot")
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
