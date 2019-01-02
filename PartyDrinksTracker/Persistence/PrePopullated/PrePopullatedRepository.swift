//
//  PrePopullatedRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 28/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation
import CoreData

class PrePopullatedRepository {
    private let drinkTypeEntityCollectionName: String! = "DrinkTypeEntity"
    private let context: DrinksDatabaseContext!
    
    init(_ context: DrinksDatabaseContext) {
        self.context = context
    }
    
    public func CleanPrePopullatedDrinkTypes() throws {
        let drinkTypesRepository = DrinkTypesRepository(self.context)
        let drinkTypes = try drinkTypesRepository.GetAll()
        try drinkTypesRepository.Delete(drinkTypes)
    }
    
    public func PrePopullateDrinkTypesFrom(jsonObject: Any) throws {
        guard let dictionary = jsonObject as? [String: Any] else {
            throw SerializationError.invalid("jsonObject", jsonObject)
        }
        
        let drinkTypes = try GetDrinkTypesFrom(dictionary)
        let drinkCapacities = try GetDrinkCapacitiesFrom(dictionary)
        
        try MapDrinkTypesToCapacitiesFrom(dictionary, drinkTypes, drinkCapacities)
    }
    
    private func GetDrinkTypesFrom(_ dictionary: [String:Any])
        throws -> [Int32: DrinkTypeEntity] {
            guard let types = dictionary["types"] as? [String: String] else {
                throw SerializationError.missing("types")
            }
            
            let drinkTypes = types.map(
            {
                item -> DrinkTypeEntity in
                let entity = DrinkTypeEntity(context: self.context.Current)
                entity.id = Int32(item.key)!
                entity.name = item.value
                return entity
            })
            .reduce(into: [Int32: DrinkTypeEntity]()) {$0[$1.id] = $1}
            
            return drinkTypes
    }
    
    private func GetDrinkCapacitiesFrom(_ dictionary: [String:Any])
        throws -> [Int32: DrinkCapacityEntity] {
            guard let capacities = dictionary["capacities"] as? [String:String] else {
                throw SerializationError.missing("capacities")
            }
            
            let drinkCapacities = capacities.map(
            {
                item -> DrinkCapacityEntity in
                let entity = DrinkCapacityEntity(context: self.context.Current)
                entity.id = Int32(item.key)!
                entity.name = item.value
                return entity
            })
            .reduce(into: [Int32: DrinkCapacityEntity]()) {$0[$1.id] = $1}
            
            return drinkCapacities
    }
    
    private func MapDrinkTypesToCapacitiesFrom(
        _ dictionary: [String:Any],
        _ drinkTypes: [Int32: DrinkTypeEntity],
        _ drinkCapacities: [Int32: DrinkCapacityEntity]) throws {
            guard let typesCapacities = dictionary["typesCapacities"] as? [[String: Any]] else {
                throw SerializationError.missing("typesCapacities")
            }
        
            for typesCapacity in typesCapacities {
                guard let typeId = typesCapacity["typeId"] as? String,
                    let capacityId = typesCapacity["capacityId"] as? String else
                {
                    throw SerializationError.invalid("Invalid type capacity mapping", typesCapacity)
                }
                
                guard let drinkTypeId = Int32(typeId),
                    let drinkType = drinkTypes[drinkTypeId] else {
                        throw SerializationError.invalid("Invalid typeId", typeId)
                }
                
                guard let drinkCapacityId = Int32(capacityId),
                    let drinkCapacity = drinkCapacities[drinkCapacityId] else {
                        throw SerializationError.invalid("Invalid capacityId", capacityId)
                }
                
                drinkType.addToCapacities(drinkCapacity)
            }
    }
}
