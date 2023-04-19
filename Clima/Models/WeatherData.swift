//
//  WeatherData.swift
//  Clima
//
//  Created by Varun Kumar on 17/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

struct WeatherData : Codable {
    let name : String
    let main :  Main
    let weather : [Weather]
    let timezone : Date
   
}


struct Main : Codable {
    let temp : Double
    let feels_like : Double
    let temp_min : Double
    let temp_max : Double
    let pressure : Int
    let humidity : Int
}

struct Weather : Codable {
    let description : String
    let id : Int
    let icon: String
    var weatherIconURl : URL{
        let urlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        return URL(string: urlString)!
    }
    
}

    
