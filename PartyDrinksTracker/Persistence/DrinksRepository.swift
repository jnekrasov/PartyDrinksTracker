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
        let entity = DrinkEntity(context: self.context)
        
        entity.id = drink.id
        entity.price = drink.price
        entity.created = drink.created
        entity.type = try GetDrinkTypeFor(drink)
    }
    
    public func GetAllForInterval(_ timeInterval: TimeInterval) throws -> [Drink] {
        let untilDate = NSDate(timeIntervalSinceNow: timeInterval)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.drinkEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "created <= %@", untilDate)
        fetchRequest.relationshipKeyPathsForPrefetching = ["type"]
        
        let drinkEntities = try self.context.fetch(fetchRequest) as! [DrinkEntity]
        
        return drinkEntities.map({ (entity: DrinkEntity) -> Drink in
            let drink = Drink(type: DrinkType(rawValue: entity.type!.id))
            drink.created = entity.created
            drink.price = entity.price
            drink.id = entity.id
            return drink
        })
    }
    
    private func GetDrinkTypeFor(_ drink: Drink!) throws -> DrinkTypeEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: DrinkTypesRepository.drinkTypeEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "name == %@", drink.type.debugDescription)
        
        let drinkTypeEntities =
            try self.context.fetch(fetchRequest) as! [DrinkTypeEntity]
        
        if (drinkTypeEntities.count > 1) {
            throw RuntimeError("More then one DrinkTypeEntity was returned.")
        }
        
        return drinkTypeEntities[0];
    }
    

}
