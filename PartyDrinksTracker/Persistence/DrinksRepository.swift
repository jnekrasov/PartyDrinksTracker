//
//  DrinksRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 24/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation
import CoreData

class DrinksRepository: IDrinksRepository {    
    private let drinkEntityCollectionName: String! = "DrinkEntity"
    
    private let context: NSManagedObjectContext!
    
    init(_ context: DrinksDatabaseContext!) {
        self.context = context.Current
    }
    
    public func Add(drink: Drink!) throws {
        let drinkEntity = DrinkEntity(context: self.context)
        drinkEntity.id = drink.id
        drinkEntity.price = drink.price
        drinkEntity.created = drink.created
        drinkEntity.type = try GetDrinkTypeFor(drink)
        drinkEntity.capacity = try GetDrinkCapacity(drink)
    }
    
    public func GetAllForInterval(_ timeInterval: TimeInterval) throws -> [Drink] {
        let untilDate = NSDate(timeIntervalSinceNow: timeInterval)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.drinkEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "created <= %@", untilDate)
        
        let drinkEntities = try self.context.fetch(fetchRequest) as! [DrinkEntity]
        
        return drinkEntities.map({ (entity: DrinkEntity) -> Drink in
            let drink = Drink(type: DrinkType(rawValue: entity.type!.id))
            drink.created = entity.created
            drink.price = entity.price
            drink.id = entity.id
            return drink
        })
    }
    
    private func GetDrinkCapacity(_ drink: Drink!) throws -> DrinkCapacityEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DrinkCapacitiesRepository.drinkCapacityEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(drink.capacity.rawValue))
        fetchRequest.fetchLimit = 1
        
        let drinkCapacityEntities =
            try self.context.fetch(fetchRequest)
        
        return drinkCapacityEntities.first as? DrinkCapacityEntity;
    }
    
    private func GetDrinkTypeFor(_ drink: Drink!) throws -> DrinkTypeEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DrinkTypesRepository.drinkTypeEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(drink.type.rawValue))
        fetchRequest.fetchLimit = 1
        
        let drinkTypeEntities =
            try self.context.fetch(fetchRequest)
        
        return drinkTypeEntities.first as? DrinkTypeEntity;
    }
    

}
