//
//  CigarretesRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 03/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import Foundation
import CoreData

class CigarretesRepository {
    private static let cigarreteEntityCollectionName: String! = "CigarreteEntity"
    private let context: NSManagedObjectContext!
    
    init(_ context: DrinksDatabaseContext!) {
        self.context = context.Current
    }
    
    public func Add(_ cigarrete: Cigarrete!) throws {
        let drinkEntity = CigarreteEntity(context: self.context)
        drinkEntity.id = cigarrete.id
        drinkEntity.created = cigarrete.created
    }
    
    public func GetAllForInterval(_ timeInterval: TimeInterval) throws -> [Cigarrete] {
        let untilDate = NSDate(timeIntervalSinceNow: timeInterval)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CigarretesRepository.cigarreteEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "created <= %@", untilDate)
        
        let cigarreteEntities = try self.context.fetch(fetchRequest) as! [CigarreteEntity]
        
        return cigarreteEntities.map({ (entity: CigarreteEntity) -> Cigarrete in
            let cigarrete = Cigarrete()
            cigarrete.id = entity.id
            cigarrete.created = entity.created
            return cigarrete
        })
    }
}
