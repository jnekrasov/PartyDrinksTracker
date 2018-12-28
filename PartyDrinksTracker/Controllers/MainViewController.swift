//
//  MainViewController.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 20/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    private var drinks: Dictionary<DrinkType, [Drink]> = [:]
    
    @IBOutlet weak var beerCount: UIButton!
    @IBOutlet weak var wineCount: UIButton!
    @IBOutlet weak var shotsCount: UIButton!
    @IBOutlet weak var cigarretesCount: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            let drinksRepository = DrinksRepository(DrinksDatabaseContext())
            
            drinks = Dictionary(
                grouping: try drinksRepository.GetAllForInterval(TimeInterval(8 * 60 * 60)),
                by: {$0.type})
            
            updateDrinksCounts()
            
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
        let sequeIdentifier = segue.identifier
        controller.updateCurrentDrink(drink: DrinksFactory.CreateFrom(segueIdentifier: sequeIdentifier))
        controller.updateTitle(title: DrinksFactory.GetDrinkTitleFrom(
            segueIdentifier: sequeIdentifier,
            drinksCount: drinks[DrinksFactory.GetDrinkTypeFrom(segueIdentifier: sequeIdentifier)]?.count))
    }
    
    private func updateDrinksCounts() {
        if let beers = drinks[DrinkType.Beer] {
            beerCount.setTitle(String(beers.count), for: UIControl.State.normal)
            beerCount.backgroundColor = getDrinksCountColor(beers.count)
        }
        
        if let wines = drinks[DrinkType.Wine] {
            wineCount.setTitle(String(wines.count), for: UIControl.State.normal)
            wineCount.backgroundColor = getDrinksCountColor(wines.count)
        }
        
        if let shots = drinks[DrinkType.Shots] {
            shotsCount.setTitle(String(shots.count), for: UIControl.State.normal)
            shotsCount.backgroundColor = getDrinksCountColor(shots.count)
        }
    }
    
    private func getDrinksCountColor(_ count: Int) -> UIColor {
        switch count {
            case _ where count <= 3:
                return UIColor(red:0.00, green:0.80, blue:0.40, alpha:1.0)
            case _ where count > 3 && count <= 5:
                return UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0)
            default:
                return UIColor(red:1.00, green:0.30, blue:0.30, alpha:1.0)
        }
    }
}
