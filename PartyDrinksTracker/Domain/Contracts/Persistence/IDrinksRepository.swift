//
//  IDrinksRepository.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 25/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import Foundation

protocol IDrinksRepository {
    func Add(drink: Drink!) throws
}
