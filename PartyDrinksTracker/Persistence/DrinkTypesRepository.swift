//
//  DrinkTypesRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 27/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation
import CoreData

class DrinkTypesRepository: IDrinkTypesRepository {
    public static let drinkTypeEntityCollectionName: String! = "DrinkTypeEntity"
    private let context: NSManagedObjectContext!
    
    init(_ context: DrinksDatabaseContext!) {
        self.context = context.Current
    }
    
    public func GetAll() throws -> [DrinkType] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DrinkTypesRepository.drinkTypeEntityCollectionName)
        let drinkTypeEntities =
            try self.context.fetch(fetchRequest) as! [DrinkTypeEntity]
        
        return drinkTypeEntities.map({
            (entity: DrinkTypeEntity) -> DrinkType
            in return DrinkType(rawValue: entity.id)!})
    }
    
    public func Delete(_ drinkType: DrinkType!) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DrinkTypesRepository.drinkTypeEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(drinkType.rawValue))
        fetchRequest.fetchLimit = 1
        
        let drinkTypeEntities =
            try self.context.fetch(fetchRequest) as! [DrinkTypeEntity]
        
        self.context.delete(drinkTypeEntities.first!)
    }
    
    public func Add(_ drinkType: DrinkType!) throws {
        let entity = DrinkTypeEntity(context: self.context)
        entity.id = drinkType.rawValue
        entity.name = String(drinkType.debugDescription)
    }
    
    public func Add(_ drinkTypes: [DrinkType]) throws {
        for drinkType in drinkTypes {
            try self.Add(drinkType)
        }
    }
    
    public func Delete(_ drinkTypes: [DrinkType]) throws {
        for drinkType in drinkTypes {
            try self.Delete(drinkType)
        }
    }
}
