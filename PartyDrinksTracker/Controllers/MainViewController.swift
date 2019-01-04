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
    private var cigarretes: [Cigarrete] = []
    private let context: DrinksDatabaseContext!
    private let drinksRepository: DrinksRepository!
    private let cigarretesRepository: CigarretesRepository!
    
    
    @IBOutlet weak var beerCount: UIButton!
    @IBOutlet weak var wineCount: UIButton!
    @IBOutlet weak var shotsCount: UIButton!
    @IBOutlet weak var cigarretesCount: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    required init?(coder aDecoder: NSCoder) {
        self.context = DrinksDatabaseContext()
        self.drinksRepository = DrinksRepository(context)
        self.cigarretesRepository = CigarretesRepository(context)
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func OnCigarreteAdded(_ sender: Any) {
        do {
            let created = Cigarrete()
            cigarretes.append(created)
            try cigarretesRepository.Add(Cigarrete())
            context.SaveChanges()
            updateCounts()
        } catch {
            fatalError("Cannot add newly smoked cigarrete :)")
        }
        updateCounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            let interval = TimeInterval(8 * 60 * 60)
            drinks = Dictionary(
                grouping: try drinksRepository.GetAllForInterval(interval),
                by: {$0.type})
            
            cigarretes = try cigarretesRepository.GetAllForInterval(interval)
        } catch {
            fatalError("Cannot get persisted drinks or cigarretes")
        }
        
        updateCounts()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        self.scrollView.isDirectionalLockEnabled = true
        //CGSizeMake(self.view.frame.width, self.view.frame.height+100)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! InputViewController
        let sequeIdentifier = segue.identifier
        let creatableDrinkType = DrinksHelperFactory.GetDrinkTypeFrom(segueIdentifier: sequeIdentifier)
        
        controller.updateCurrentDrinkType(creatableDrinkType)
        controller.updateTitle(
            title: DrinksHelperFactory.GetDrinkTitleFrom(
                segueIdentifier: sequeIdentifier,
                drinksCount: drinks[creatableDrinkType]?.count))
    }
    
    private func updateCounts() {
        if let beers = drinks[DrinkType.Beer] {
            beerCount.setTitle(String(beers.count), for: .normal)
            beerCount.backgroundColor = getCountColor(beers.count)
        }
        
        if let wines = drinks[DrinkType.Wine] {
            wineCount.setTitle(String(wines.count), for: .normal)
            wineCount.backgroundColor = getCountColor(wines.count)
        }
        
        if let shots = drinks[DrinkType.Shots] {
            shotsCount.setTitle(String(shots.count), for: .normal)
            shotsCount.backgroundColor = getCountColor(shots.count)
        }
        
        cigarretesCount.setTitle(String(cigarretes.count), for: .normal)
        cigarretesCount.backgroundColor = getCountColor(cigarretes.count)
    }
    
    private func getCountColor(_ count: Int) -> UIColor {
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
