//
//  MainViewController.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 20/12/2018.
//  Copyright © 2018 Jevgenij Nekrasov. All rights reserved.
//

import UIKit
import Firebase

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
    @IBOutlet weak var beerPrice: UIButton!
    @IBOutlet weak var winePrice: UIButton!
    @IBOutlet weak var shotsPrice: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        self.context = DrinksDatabaseContext()
        self.drinksRepository = DrinksRepository(context)
        self.cigarretesRepository = CigarretesRepository(context)
        
        super.init(coder: aDecoder)
    }
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBAction func OnCigarreteAdded(_ sender: Any) {
        do {
            let created = Cigarrete()
            cigarretes.append(created)
            try cigarretesRepository.Add(Cigarrete())
            context.SaveChanges()
            updateCounts()
            if let tabController = self.tabBarController,
                let historyController = tabController.viewControllers?[1] as? DrinksHistoryViewController {
                historyController.updateCigarretesHistory(with: created)
            }
        } catch {
            fatalError("Cannot add newly smoked cigarrete :)")
        }
        updateCounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        self.scrollView.isDirectionalLockEnabled = true
        updateCounts()
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetPriceColorViews()
        do {
            let currentPartyStartedDate = UserDefaultsRepository.PartyStartedDate
            drinks = Dictionary(
                grouping: try drinksRepository.GetAllStarting(from: currentPartyStartedDate),
                by: {$0.type})
            
            cigarretes = try cigarretesRepository.GetAllStarting(from: currentPartyStartedDate)
        } catch {
            fatalError("Cannot get persisted drinks or cigarretes")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! DrinkInputViewController
        let sequeIdentifier = segue.identifier
        let creatableDrinkType = DrinkExtensions.GetDrinkTypeFrom(segueIdentifier: sequeIdentifier)
        
        controller.updateCurrentDrinkType(creatableDrinkType)
        controller.updateTitle(
            title: DrinkExtensions.GetDrinkTitleFrom(
                segueIdentifier: sequeIdentifier,
                drinksCount: drinks[creatableDrinkType]?.count))
    }
    
    private func updateCounts() {
        if let beers = drinks[DrinkType.Beer] {
            beerCount.setTitle(String(beers.count), for: .normal)
            beerCount.backgroundColor = getCountColor(beers.count)
            beerPrice.setTitle(beers.reduce(0, {$0 + $1.price}).formattedCurrencyValue, for: .normal)
            beerPrice.backgroundColor = getCountColor(beers.count)
        }
        
        if let wines = drinks[DrinkType.Wine] {
            wineCount.setTitle(String(wines.count), for: .normal)
            wineCount.backgroundColor = getCountColor(wines.count)
            winePrice.setTitle(wines.reduce(0, {$0 + $1.price}).formattedCurrencyValue, for: .normal)
            winePrice.backgroundColor = getCountColor(wines.count)
        }
        
        if let shots = drinks[DrinkType.Shots] {
            shotsCount.setTitle(String(shots.count), for: .normal)
            shotsCount.backgroundColor = getCountColor(shots.count)
            shotsPrice.setTitle(shots.reduce(0, {$0 + $1.price}).formattedCurrencyValue, for: .normal)
            shotsPrice.backgroundColor = getCountColor(shots.count)
        }
        
        cigarretesCount.setTitle(String(cigarretes.count), for: .normal)
        cigarretesCount.backgroundColor = getCountColor(cigarretes.count)
    }
    
    private func resetPriceColorViews() {
        let initialPrice = Decimal(0).formattedCurrencyValue
        beerPrice.backgroundColor = getCountColor(0)
        beerCount.backgroundColor = getCountColor(0)
        beerPrice.setTitle(initialPrice, for: .normal)
        winePrice.backgroundColor = getCountColor(0)
        wineCount.backgroundColor = getCountColor(0)
        winePrice.setTitle(initialPrice, for: .normal)
        shotsPrice.backgroundColor = getCountColor(0)
        shotsCount.backgroundColor = getCountColor(0)
        shotsPrice.setTitle(initialPrice, for: .normal)
        cigarretesCount.backgroundColor = getCountColor(0)
    }
    
    private func getCountColor(_ count: Int) -> UIColor {
        switch count {
            case _ where count <= 3:
                return UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
            case _ where count > 3 && count <= 5:
                return UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0)
            default:
                return UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0)
        }
    }
    
    public func updateDrinkCollection(with drink: Drink!) {
        if var drinksCollection = self.drinks[drink.type] {
            drinksCollection.append(drink)
            drinks[drink.type] = drinksCollection
        }
        else {
            self.drinks[drink.type] = [drink]
        }
        
        if let tabController = self.tabBarController,
            let historyController = tabController.viewControllers?[1] as? DrinksHistoryViewController {
            historyController.updateDrinksHistory(with: drink)
        }
    }
    
    public func removeDrink(_ drink: Drink!) {
        if var drinksCollection = self.drinks[drink.type] {
            drinksCollection.removeAll(where: {$0.id == drink.id})
            self.drinks[drink.type] = drinksCollection
            updateCounts()
        }
    }
    
    @IBAction func onInputCompleted(_ segue: UIStoryboardSegue) {
        let segueIdentifier = segue.identifier
        
        if segueIdentifier == "onDrinkAddedSegue" {
            updateCounts()
        }
    }
}
