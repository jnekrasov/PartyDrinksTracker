//
//  InputViewController.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 24/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {
    private var drinkTypesCapacities: [DrinkType: [DrinkCapacity]]?
    private var currentDrinkType: DrinkType?
    private var currentDrink: Drink?
    private var currentTitle: String?
    private var currentCapacities: [DrinkCapacity]?
    
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = currentTitle
        let font = UIFont.systemFont(ofSize: 16)
        drinkCapacitySelector.setTitleTextAttributes(
            [NSAttributedString.Key.font: font],
            for: .normal)
        
        for i in 0...currentCapacities!.count-1 {
            drinkCapacitySelector.setTitle(
                String(describing: currentCapacities![i]),
                forSegmentAt: i)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var drinkCapacitySelector: UISegmentedControl!
    @IBOutlet weak var currentPriceInput: UITextField!
    
    @IBAction func OnDrinkAdded(_ sender: Any) {
        do {
            let context = DrinksDatabaseContext()
            let drinksRepository = DrinksRepository(context)
            currentDrink?.price = Double(currentPriceInput.text!)
            try drinksRepository.Add(drink: currentDrink)
            context.SaveChanges()
            OnClosePopup(sender)
        } catch {
            fatalError("Cannot save your selected drink")
        }
    }
    
    @IBAction func OnClosePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    public func updateCurrentDrinkType(_ drinkType: DrinkType!) {
        currentDrinkType = drinkType
        currentDrink = Drink(type: currentDrinkType)
        
        do {
            let context = DrinksDatabaseContext()
            let drinkCapacitiesRepository = DrinkCapacitiesRepository(context)
            currentCapacities = try drinkCapacitiesRepository.GetFor(drinkType: currentDrinkType!)
        } catch {
            fatalError("Cannot get capacities for selected drink: [\(currentDrinkType.debugDescription)]")
        }
    }
    
    public func updateTitle(title: String!) {
        self.currentTitle = title;
    }
}
