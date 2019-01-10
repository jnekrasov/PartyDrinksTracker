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
    
    public func GetAllStarting(from partyStartedDate: Date!) throws -> [Cigarrete] {
        let partyStarted = NSDate(timeIntervalSince1970: partyStartedDate.timeIntervalSince1970)
        let partyEnded = partyStarted.addingTimeInterval(TimeInterval(10 * 60 * 60))
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CigarretesRepository.cigarreteEntityCollectionName)
        fetchRequest.predicate = NSPredicate(format: "created >= %@ && created <= %@", partyStarted, partyEnded)
        
        let cigarreteEntities = try self.context.fetch(fetchRequest) as! [CigarreteEntity]
        
        return ToDomain(cigarreteEntities)
    }
    
    public func GetAll() throws -> [Cigarrete] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CigarretesRepository.cigarreteEntityCollectionName)
        
        let cigarreteEntities = try self.context.fetch(fetchRequest) as! [CigarreteEntity]
        
        return ToDomain(cigarreteEntities)
    }
    
    private func ToDomain(_ cigarreteEntities: [CigarreteEntity]) -> [Cigarrete] {
        return cigarreteEntities.map({ (entity: CigarreteEntity) -> Cigarrete in
            let cigarrete = Cigarrete()
            cigarrete.id = entity.id
            cigarrete.created = entity.created
            return cigarrete
        })
    }
}
