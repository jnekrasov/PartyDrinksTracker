//
//  InputViewController.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 24/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import UIKit

class InputViewController: UIViewController {
    private var currentDrink: Drink?
    private var currentTitle: String?
    
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = currentTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
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
    
    public func updateTitle(title: String!) {
        self.currentTitle = title;
    }
    
    public func updateCurrentDrink(drink: Drink!) {
        self.currentDrink = drink
    }
}
