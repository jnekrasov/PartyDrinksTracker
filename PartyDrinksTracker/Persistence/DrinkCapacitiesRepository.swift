//
//  DrinkCapacitiesRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 02/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import Foundation
import CoreData

class DrinkCapacitiesRepository {
    private var context: NSManagedObjectContext
    
    public static let drinkCapacityEntityCollectionName: String = "DrinkCapacityEntity"
    
    init(_ context: DrinksDatabaseContext!) {
        self.context = context.Current
    }
    
    public func GetFor(drinkType: DrinkType) throws -> [DrinkCapacity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
            entityName: DrinkTypesRepository.drinkTypeEntityCollectionName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@", String(drinkType.rawValue))
        
        guard let drinkTypesEntities = try self.context.fetch(fetchRequest) as? [DrinkTypeEntity],
            let drinkTypeEntity = drinkTypesEntities.first,
            let capacities = drinkTypeEntity.capacities?.allObjects as? [DrinkCapacityEntity] else {
                throw PersistenceError.notFound("Cannot find drink capacities for \(drinkType.rawValue)")
        }
        return capacities.map({
            item -> DrinkCapacity in
            let capacity = DrinkCapacity(rawValue: item.id)
            return capacity!
        })
        .sorted(by: { (current, other)-> Bool in return current.rawValue < other.rawValue})
    }
}
