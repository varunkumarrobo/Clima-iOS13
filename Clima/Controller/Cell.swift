//
//  MyTableView.swift
//  Clima
//
//  Created by Varun Kumar on 26/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    
    @IBOutlet var favImaLabel: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var descripLabel: UILabel!
    @IBOutlet var favImageView: UIImageView!
    @IBOutlet var favButton: UIButton!
    
    var deleteButtonAction: (() -> Void)?
    
    func setNames(itemArray: WeatherDB)  {
        cityLabel.text = "\(String(format: itemArray.place!)),"
        countryLabel.text = itemArray.country
    }
    
    @IBAction func favButton(_ sender: UIButton) {
        print("Fav Button at Favourties Page..")
        deleteButtonAction?()
    }
    
    func setSearchs(searchArray: RecentSearch)  {
        cityLabel.text = "\(String(format: (searchArray.searchPlace?.capitalized)!))"
        countryLabel.text = searchArray.searchCountry
    }
    
}


//func setDetails(modelArray: WeatherModel){
//    tempLabel.text = String(modelArray.temp)
//    favImaLabel.image = UIImage(systemName: modelArray.conditionName)
//    descripLabel.text = modelArray.description
//}

//func setDetails(favImage: UIImage,temp: Array<String>,descrip: Array<String>)  {
//    favImaLabel.image = favImage
//    tempLabel.text = temp[0]
//    descripLabel.text = descrip[0]
//}
