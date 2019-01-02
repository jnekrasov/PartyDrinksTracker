//
//  PersistenceError.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 02/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

enum PersistenceError: Error {
    case notFound(String)
}
