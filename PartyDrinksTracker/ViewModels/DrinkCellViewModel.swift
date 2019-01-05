//
//  DrinkCellViewModel.swift
//  PartyDrinksTracker
//
//  Created by Jevgenij Nekrasov on 05/01/2019.
//  Copyright © 2019 Jevgenij Nekrasov. All rights reserved.
//

import UIKit

class DrinkCellViewModel: UITableViewCell {
    
    @IBOutlet var drinkThumbnailView: UIImageView!
    @IBOutlet var drinkTitleLabel: UILabel!
    @IBOutlet var drinkPriceLabel: UILabel!
    @IBOutlet var drinkDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
