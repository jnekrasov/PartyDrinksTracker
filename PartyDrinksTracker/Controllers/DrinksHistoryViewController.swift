//
//  DrinksHistoryViewController.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 05/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import UIKit

class DrinksHistoryViewController: UITableViewController {
    private var drinks: [Drink] = []
    private var drinksRepository: DrinksRepository!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.drinksRepository = DrinksRepository(DrinksDatabaseContext())
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let drinkCellViewModel = tableView.dequeueReusableCell(
            withIdentifier: "drinkViewCell",
            for: indexPath) as! DrinkCellViewModel
        
        let index = indexPath.row
        let currentDrink = drinks[index]
        drinkCellViewModel.drinkDateLabel?.text = GetDrinkDatePresentation(currentDrink.created)
        drinkCellViewModel.drinkTitleLabel?.text = GetDrinkTitleRepresentation(currentDrink)
        drinkCellViewModel.drinkThumbnailView.image = GetDrinkImageRepresentation(currentDrink)
        drinkCellViewModel.drinkPriceLabel?.text = String(format: "%.1f€$", currentDrink.price)
        
        return drinkCellViewModel
    }
    
    @IBOutlet var drinksViewTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            drinksViewTable.reloadData()
            drinks = try drinksRepository.GetAllForInterval(TimeInterval(8 * 60 * 60))
        } catch {
            fatalError("Cannot get drinks list to popullate")
        }

        self.drinksViewTable.rowHeight = 95
        super.viewWillAppear(animated)
    }
    
    private func GetDrinkImageRepresentation(_ drink: Drink!) -> UIImage {
        switch drink.type! {
            case .Beer:
                return UIImage(named: "Beer")!
            case .Wine:
                return UIImage(named: "Wine")!
            default:
                return UIImage(named: "Shots")!
        }
    }
    
    private func GetDrinkTitleRepresentation(_ drink: Drink!) -> String {
        let capacity = DrinksHelperFactory.GetDrinkCapacityRepresentation(drink.capacity)
        let type = DrinksHelperFactory.GetDrinkTypeRepresentation(drink.type)
        
        switch drink.type! {
            case .Beer:
                return "\(capacity) \(type)"
            case .Wine:
                return "\(capacity) of \(type)"
        default:
            if (drink.capacity == DrinkCapacity.Bottle) {
                return "Uuuuh \(capacity) of 'shots'"
            }
            
            return capacity
        }
        
    }
    
    private func GetDrinkDatePresentation(_ drinkDate: Date!) -> String! {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE (dd.MM.YYYY)"
        formatter.locale = Locale.current
        let dateRepresentation = formatter.string(from: drinkDate)
        
        return "on \(dateRepresentation)"
    }
}
