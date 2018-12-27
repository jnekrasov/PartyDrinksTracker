//
//  MainViewController.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 20/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    private var drinks: [Drink] = []
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            let context = DrinksDatabaseContext()
            let drinkTypesRepository = DrinkTypesRepository(context)
            let drinksRepository = DrinksRepository(context)
            _ = try drinkTypesRepository.GetAll()
            drinks = try drinksRepository.GetAllForInterval(TimeInterval(8 * 60 * 60))
        } catch {
            fatalError("Cannot get all persisted drinks")
        }

        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! InputViewController
        controller.updateCurrentDrink(drink: DrinksFactory.CreateFromSeque(sequeIdentifier: segue.identifier))
    }
}
