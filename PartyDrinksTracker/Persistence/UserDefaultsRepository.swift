//
//  UserDefaultsRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 02/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

class UserDefaultsRepository {
    private struct UserDrinkDefaults: Codable {
        var DefaultCapacityIndex: Int?
        var DefaultDrinkPrice: Decimal?
    }
    
    private static let isPrePopullatedParameterName = "isPrePopullated"
    private static let defaults = UserDefaults.standard
    
    public static var AreDrinkTypesPrePopullated: Bool {
        get {
            return UserDefaultsRepository.defaults.bool(forKey: UserDefaultsRepository.isPrePopullatedParameterName)
        }
        set {
            UserDefaultsRepository.defaults.set(newValue, forKey: UserDefaultsRepository.isPrePopullatedParameterName)
        }
    }
    
    private static let partyStartedDateParameterName = "partyStartedDate"
    public static var PartyStartedDate: Date! {
        var nextPartyDate = Date()
        
        if let previuosPartyStarted = UserDefaultsRepository.defaults.object(forKey: partyStartedDateParameterName) as? Date
        {
            nextPartyDate = previuosPartyStarted.addingTimeInterval(TimeInterval(10 * 60 * 60))
            if nextPartyDate > Date() {
                return previuosPartyStarted
            }
        }
    
        UserDefaultsRepository.defaults.set(nextPartyDate, forKey: partyStartedDateParameterName)
        return nextPartyDate
    }
    
    public static func SetDrinkTypeCapacityDefaultIndexFor(drinkType: DrinkType!, index: Int!) {
        var userDrinkDefaults = GetUserDrinkDefaults(forDrinkType: drinkType)
        userDrinkDefaults.DefaultCapacityIndex = index
        SetUserDrinkDefaults(forDrinkType: drinkType, drinkDefaults: userDrinkDefaults)
    }
    
    public static func GetDrinkTypeCapacityDefaultIndexFor(drinkType: DrinkType) -> Int? {
        let userDrinkDefaults = GetUserDrinkDefaults(forDrinkType: drinkType)
        return userDrinkDefaults.DefaultCapacityIndex
    }
    
    public static func SetDrinkTypeDefaultPrice(forDrinkType: DrinkType!, price: Decimal!) {
        var userDrinkDefaults = GetUserDrinkDefaults(forDrinkType: forDrinkType)
        userDrinkDefaults.DefaultDrinkPrice = price
        SetUserDrinkDefaults(forDrinkType: forDrinkType, drinkDefaults: userDrinkDefaults)
    }
    
    public static func GetDrinkTypeDefaultPrice(forDrinkType: DrinkType!) -> Decimal? {
        let userDrinkDefaults = GetUserDrinkDefaults(forDrinkType: forDrinkType)
        return userDrinkDefaults.DefaultDrinkPrice
    }
    
    private static func SetUserDrinkDefaults(forDrinkType: DrinkType!, drinkDefaults: UserDrinkDefaults!) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(drinkDefaults) {
            UserDefaultsRepository.defaults.set(encoded, forKey: String(describing: forDrinkType))
        }
    }
    
    private static func GetUserDrinkDefaults(forDrinkType: DrinkType!) -> UserDrinkDefaults {
        var loadedDefaults: UserDrinkDefaults?
        
        if let userDrinkDefaults
            = UserDefaultsRepository.defaults.object(forKey: String(describing: forDrinkType)) as? Data {
            let decoder = JSONDecoder()
            loadedDefaults = try? decoder.decode(UserDrinkDefaults.self, from: userDrinkDefaults)
        }
        
        return loadedDefaults ?? UserDrinkDefaults()
    }
}
