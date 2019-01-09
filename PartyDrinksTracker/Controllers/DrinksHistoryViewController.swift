//
//  DrinksHistoryViewController.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 05/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import UIKit

class DrinksHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var dailyDrinks: [DailyDrinksViewModel] = []
    private var dailyCigarretes: [DailyCigarretesViewModel] = []
    
    private var drinksRepository: DrinksRepository!
    private var cigarretesRepository: CigarretesRepository!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let context = DrinksDatabaseContext()
        self.drinksRepository = DrinksRepository(context)
        self.cigarretesRepository = CigarretesRepository(context)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section >= self.dailyDrinks.count {
            return 0
        }
        
        let section = self.dailyDrinks[section]
        return section.drinks.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dailyDrinksHeaderViewModel = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "drinksHeaderViewCell") as! DailyDrinksHeaderViewModel
        
        var sectionDate: Date?
        var sectionDrinks: [Drink]?
        var sectionCigarretes: [Cigarrete]?
        
        if section >= dailyDrinks.count {
            sectionDate = dailyCigarretes[section].cigarretesDate
            sectionDrinks = []
            sectionCigarretes = dailyCigarretes[section].cigarretes
        }
        else {
            sectionDate = dailyDrinks[section].drinksDate
            sectionDrinks = dailyDrinks[section].drinks
            sectionCigarretes = dailyCigarretes.first(where: {$0.cigarretesDate == sectionDate})?.cigarretes ?? []
        }
        
        dailyDrinksHeaderViewModel.cigarretesCount?.text = String(sectionCigarretes!.count)
        dailyDrinksHeaderViewModel.dailyDrinksDateTitle?.text = GetDrinkDatePresentation(sectionDate)
        dailyDrinksHeaderViewModel.dailyDrinksTotalPrice?.text = sectionDrinks!.reduce(0, {$0 + $1.price}).formattedValue
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.83, green:0.84, blue:0.81, alpha:1.0)
        dailyDrinksHeaderViewModel.backgroundView = backgroundView
        
        return dailyDrinksHeaderViewModel
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let drinkCellViewModel = tableView.dequeueReusableCell(
            withIdentifier: "drinkViewCell",
            for: indexPath) as! DrinkCellViewModel
        
        var section = dailyDrinks[indexPath.section]
        let currentDrink = section.drinks[indexPath.row]
        drinkCellViewModel.drinkDateLabel?.text = GetDrinkDatePresentation(currentDrink.created)
        drinkCellViewModel.drinkTitleLabel?.text = GetDrinkTitleRepresentation(currentDrink)
        drinkCellViewModel.drinkThumbnailView.image = GetDrinkImageRepresentation(currentDrink)
        drinkCellViewModel.drinkPriceLabel?.text = currentDrink.price.formattedValue
        
        return drinkCellViewModel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dailyDrinks.count > self.dailyCigarretes.count
            ? self.dailyDrinks.count
            : self.dailyCigarretes.count
    }
    
    @IBOutlet weak var drinksViewTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            drinksViewTable.reloadData()
            let drinks = try drinksRepository.GetAllForInterval(TimeInterval(8 * 60 * 60))
            let cigarretes = try cigarretesRepository.GetAllForInterval(TimeInterval(8 * 60 * 60))
            
            let groupedDrinks = GroupByDate(grouping: drinks)
            let groupedCigarretes = GroupByDate(grouping: cigarretes)
            
            self.dailyCigarretes = groupedCigarretes.map{
                (key, values) in return DailyCigarretesViewModel(cigarretesDate: key, cigarretes: values)
            }.sorted{$0 > $1}
            self.dailyDrinks = groupedDrinks.map {
                (key, values) in return DailyDrinksViewModel(drinksDate: key, drinks: values)
            }.sorted{$0 > $1}
        } catch {
            fatalError("Cannot get drinks list to popullate")
        }

        self.drinksViewTable.rowHeight = 77
        super.viewWillAppear(animated)
    }
    
    private func GroupByDate<T: Auditable>(grouping: [T]) -> Dictionary<Date, [T]> {
        return Dictionary(grouping: grouping) { (item) -> Date in
            let components = Calendar.current.dateComponents([.day, .month, .year], from: item.created)
            return Calendar.current.date(from: components)!
        }
    }
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "DailyDrinksHeaderCellView", bundle: nil)
        //tableView.register(nib, forHeaderFooterViewReuseIdentifier: "drinksHeaderViewCell")
        drinksViewTable.delegate = self
        drinksViewTable.dataSource = self
        drinksViewTable.register(nib, forHeaderFooterViewReuseIdentifier: "drinksHeaderViewCell")
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
        let capacity = DrinkExtensions.GetDrinkCapacityRepresentation(drink.capacity)
        let type = DrinkExtensions.GetDrinkTypeRepresentation(drink.type)
        
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
        formatter.dateFormat = "EEEE (dd.MM)"
        formatter.locale = Locale.current
        let dateRepresentation = formatter.string(from: drinkDate)
        
        return "on \(dateRepresentation)"
    }
}
