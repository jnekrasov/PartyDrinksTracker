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
    
    private let context: DrinksDatabaseContext!
    private let drinksRepository: DrinksRepository!
    private let drinkCapacitiesRepository:DrinkCapacitiesRepository!
    
    required init?(coder aDecoder: NSCoder) {
        self.context = DrinksDatabaseContext()
        self.drinksRepository = DrinksRepository(context)
        self.drinkCapacitiesRepository = DrinkCapacitiesRepository(context)
        
        super.init(coder: aDecoder)
    }
    
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
        
        drinkCapacitySelector.selectedSegmentIndex
            = UserDefaultsRepository.GetDrinkTypeCapacityDefaultIndexFor(drinkType: currentDrinkType!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var drinkCapacitySelector: UISegmentedControl!
    @IBOutlet weak var currentPriceInput: UITextField!
    
    @IBAction func OnDrinkAdded(_ sender: Any) {
        do {
            currentDrink?.price = Double(currentPriceInput.text ?? "0")
            currentDrink?.capacity = currentCapacities![drinkCapacitySelector.selectedSegmentIndex]
            try drinksRepository.Add(drink: currentDrink)
            context.SaveChanges()
            UserDefaultsRepository.SetDrinkTypeCapacityDefaultIndexFor(
                drinkType: currentDrinkType!,
                index: drinkCapacitySelector.selectedSegmentIndex)
        } catch {
            fatalError("Cannot save your selected drink")
        }
    }
    
    public func updateCurrentDrinkType(_ drinkType: DrinkType!) {
        currentDrinkType = drinkType
        currentDrink = Drink(type: currentDrinkType)
        
        do {
            currentCapacities = try drinkCapacitiesRepository.GetFor(drinkType: currentDrinkType!)
        } catch {
            fatalError("Cannot get capacities for selected drink: [\(currentDrinkType.debugDescription)]")
        }
    }
    
    public func updateTitle(title: String!) {
        self.currentTitle = title;
    }
}
