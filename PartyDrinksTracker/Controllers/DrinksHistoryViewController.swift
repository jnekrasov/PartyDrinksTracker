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
    
    private var context: DrinksDatabaseContext!
    private var drinksRepository: DrinksRepository!
    private var cigarretesRepository: CigarretesRepository!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.context = DrinksDatabaseContext()
        self.drinksRepository = DrinksRepository(self.context)
        self.cigarretesRepository = CigarretesRepository(self.context)
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
        dailyDrinksHeaderViewModel.dailyDrinksTotalPrice?.text = sectionDrinks!.reduce(0, {$0 + $1.price}).formattedCurrencyValue
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.83, green:0.84, blue:0.81, alpha:1.0)
        dailyDrinksHeaderViewModel.backgroundView = backgroundView
        
        return dailyDrinksHeaderViewModel
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            do {
                var dailyDrinksViewModel = self.dailyDrinks[indexPath.section]
                let dailyCigarretesViewModel = self.dailyCigarretes[indexPath.section]
                let drink = dailyDrinksViewModel.drinks[indexPath.row]
                dailyDrinksViewModel.drinks.remove(at: indexPath.row)
                
                if (dailyDrinksViewModel.drinks.count > 0 || dailyCigarretesViewModel.cigarretes.count > 0) {
                    self.dailyDrinks[indexPath.section] = dailyDrinksViewModel
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                else {
                    self.dailyDrinks.remove(at: indexPath.section)
                    tableView.deleteSections(IndexSet([indexPath.section]), with: .fade)
                }

                try self.drinksRepository.Delete(drink)
                self.context.SaveChanges()
                
                if let tabController = self.tabBarController,
                    let mainController = tabController.viewControllers?[0] as? MainViewController {
                    mainController.removeDrink(drink)
                }
                
                tableView.reloadData()
            }
            catch {
                fatalError("Cannot delete selected drink")
            }
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let drinkCellViewModel = tableView.dequeueReusableCell(
            withIdentifier: "drinkViewCell",
            for: indexPath) as! DrinkCellViewModel
        
        var section = dailyDrinks[indexPath.section]
        let currentDrink = section.drinks[indexPath.row]
        drinkCellViewModel.drinkDateLabel?.text = GetDrinkDateTimePresentation(currentDrink.created)
        drinkCellViewModel.drinkTitleLabel?.text = GetDrinkTitleRepresentation(currentDrink)
        drinkCellViewModel.drinkThumbnailView.image = GetDrinkImageRepresentation(currentDrink)
        drinkCellViewModel.drinkPriceLabel?.text = currentDrink.price.formattedCurrencyValue
        
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
        drinksViewTable.tableFooterView = UIView()
        super.viewWillAppear(animated)
        self.drinksViewTable.rowHeight = 77
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "DailyDrinksHeaderCellView", bundle: nil)
        drinksViewTable.delegate = self
        drinksViewTable.dataSource = self
        drinksViewTable.register(nib, forHeaderFooterViewReuseIdentifier: "drinksHeaderViewCell")
        drinksViewTable.reloadData()
        
        do {
            drinksViewTable.reloadData()
            let drinks = try drinksRepository.GetAll()
            let cigarretes = try cigarretesRepository.GetAll()
            
            let groupedDrinks = GroupByDate(grouping: drinks)
            let groupedCigarretes = GroupByDate(grouping: cigarretes)
            
            self.dailyCigarretes = groupedCigarretes.map{
                (key, values) in return DailyCigarretesViewModel(
                    cigarretesDate: key,
                    cigarretes: values.sorted{$0.created > $1.created})
                }.sorted{$0 > $1}
            self.dailyDrinks = groupedDrinks.map {
                (key, values) in return DailyDrinksViewModel(
                    drinksDate: key,
                    drinks: values.sorted{$0.created > $1.created})
                }.sorted{$0 > $1}
        } catch {
            fatalError("Cannot get drinks list to popullate")
        }
    }
    
    public func updateDrinksHistory(with drink:Drink!) {
        if (drinksViewTable == nil) {
            return
        }
        
        if var dailyDrinkViewModel = self.dailyDrinks.first(where: {$0.drinksDate == GetGroupDate(for: drink)}) {
            dailyDrinkViewModel.drinks.append(drink)
            dailyDrinkViewModel.drinks = dailyDrinkViewModel.drinks.sorted{$0.created > $1.created}
            let updatedIndex = self.dailyDrinks.firstIndex(of: dailyDrinkViewModel)!
            self.dailyDrinks[updatedIndex] = dailyDrinkViewModel
        }
        else {
            self.dailyDrinks.append(DailyDrinksViewModel(
                drinksDate: GetGroupDate(for: drink),
                drinks: [drink]))
            self.dailyDrinks = self.dailyDrinks.sorted{$0 > $1}
        }
        
        self.drinksViewTable.reloadData()
    }
    
    public func updateCigarretesHistory(with cigarrete:Cigarrete!) {
        if (drinksViewTable == nil) {
            return
        }
        
        if var dailyCigarreteViewModel = self.dailyCigarretes.first(where: {$0.cigarretesDate == GetGroupDate(for: cigarrete)}) {
            dailyCigarreteViewModel.cigarretes.append(cigarrete)
            dailyCigarreteViewModel.cigarretes = dailyCigarreteViewModel.cigarretes.sorted{$0.created > $1.created}
            let updatedIndex = self.dailyCigarretes.firstIndex(of: dailyCigarreteViewModel)!
            self.dailyCigarretes[updatedIndex] = dailyCigarreteViewModel
        }
        else {
            self.dailyCigarretes.append(DailyCigarretesViewModel(
                cigarretesDate: GetGroupDate(for: cigarrete),
                cigarretes: [cigarrete]))
            self.dailyCigarretes = self.dailyCigarretes.sorted{$0 > $1}
        }
        
        drinksViewTable.reloadData()
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
                return "Lots of shots"
            }
            
            return capacity
        }
    }
    
    private func GetDrinkDatePresentation(_ drinkDate: Date!) -> String! {
        let formatter = DateFormatter()
        formatter.dateFormat = "'on' EEEE (dd.MM)"
        formatter.locale = Locale.current
        let dateRepresentation = formatter.string(from: drinkDate)
        
        return dateRepresentation
    }
    
    private func GetDrinkDateTimePresentation(_ drinkDate: Date!) -> String! {
        let formatter = DateFormatter()
        formatter.dateFormat = "'on' EEEE 'at' HH:mm"
        formatter.locale = Locale.current
        let dateRepresentation = formatter.string(from: drinkDate)
        
        return dateRepresentation
    }
    
    private func GetGroupDate<T: Auditable>(for item: T) -> Date {
        let components = Calendar.current.dateComponents([.day, .month, .year], from: item.created)
        return Calendar.current.date(from: components)!
    }
    
    private func GroupByDate<T: Auditable>(grouping: [T]) -> Dictionary<Date, [T]> {
        return Dictionary(grouping: grouping) { (item) -> Date in
            return GetGroupDate(for: item)
        }
    }
}
