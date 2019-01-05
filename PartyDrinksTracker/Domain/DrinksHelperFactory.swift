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
            case .Beer:
                title = "\(count) "
                    + (count > 1 ? "beers" : "beer")
                    + " for today! Planning for more? :)"
            case .Wine:
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
    
    public static func GetDrinkTypeRepresentation(_ drinkType: DrinkType) -> String {
        switch drinkType {
            case .Beer:
                return "Beer"
            case .Wine:
                return "Wine"
            default:
                return "Shot"
        }
    }
    
    public static func GetDrinkCapacityRepresentation(_ drinkCapacity: DrinkCapacity) -> String {
        switch drinkCapacity {
        case .Small:
            return "Small"
        case .Big:
            return "Big"
        case .Bottle:
            return "Bottle :)"
        case .Glass:
            return "Glass"
        default:
            return "Shot"
        }
    }
    
    public static func GetDrinkTypeFrom(segueIdentifier: String!) -> DrinkType {
        switch segueIdentifier {
        case "beerSegue":
            return .Beer
        case "shotsSegue":
            return .Shots
        default:
            return .Wine
        }
    }
}
