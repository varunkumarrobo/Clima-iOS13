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
    
    func setDetails(favImage: UIImage,temp: Array<String>,descrip: Array<String>)  {
        favImaLabel.image = favImage
        tempLabel.text = temp[0]
        descripLabel.text = descrip[0]
    } 
    
}
//MARK: - WeatherManagerDelegate
//extension Cell : WeatherManagerDelegate {
//    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel)  {
//        DispatchQueue.main.async {
//            print("executed")
//            self.tempLabel.text = weather.tempratureString
//            self.favImaLabel.image = UIImage(named: weather.conditionName)
////                UIImage(systemName: weather.conditionName)
//
//            self.descripLabel.text = weather.description
//
//            print(self.tempLabel.text!)
//            print(self.descripLabel.text!)
//        }
//    }
//
//    func didFailError(error: Error) {
//        print("edfgoyuregerp \(error)")
//    }
//}
