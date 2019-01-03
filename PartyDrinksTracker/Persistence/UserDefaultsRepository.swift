//
//  UserDefaultsRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 02/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

class UserDefaultsRepository {
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
    
    public static func SetDrinkTypeCapacityDefaultIndexFor(drinkType: DrinkType, index: Int) {
        UserDefaultsRepository.defaults.set(index, forKey: String(describing: drinkType))
    }
    
    public static func GetDrinkTypeCapacityDefaultIndexFor(drinkType: DrinkType) -> Int {
        return UserDefaultsRepository.defaults.integer(forKey: String(describing: drinkType))
    }
}
