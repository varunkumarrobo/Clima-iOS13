//
//  MyTableView.swift
//  Clima
//
//  Created by Varun Kumar on 26/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    //    var weatherManager = WeatherManager()
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    
    @IBOutlet var favImaLabel: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var descripLabel: UILabel!
    
    func setNames(itemArray: WeatherDB)  {
        cityLabel.text = itemArray.place
        countryLabel.text = itemArray.country
    }
    
    func setSearchs(searchArray: RecentSearch)  {
        cityLabel.text = searchArray.searchPlace
        countryLabel.text = searchArray.searchCountry
    }
    
    func setDetails(favImage: UIImage,temp: Array<String>,descrip: Array<String>)  {
        favImaLabel.image = favImage
        tempLabel.text = temp[0]
        descripLabel.text = descrip[0]
    } 
    
}
