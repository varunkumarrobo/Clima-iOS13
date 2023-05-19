//
//  WeatherModel.swift
//  Clima
//
//  Created by Varun Kumar on 17/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation


struct WeatherModel {
    let conditionId : Int
    let cityName : String
    let temp : Double
    let description : String
    let icon : String
    let time : TimeInterval
    let countryCode : String
    let feels_like : Double
    let temp_min : Double
    let temp_max : Double
    let humidity : Int
    let visibility : Int
    
    var tempratureString : String {
        return String(format: "%.0f", temp)
    }
    
//    var timeString : Date {
//        return time
//    }
    
    var conditionName : String {
        switch conditionId {
                case 200...232:
                    return "cloud.bolt"
                case 300...321:
                    return "cloud.drizzle"
                case 500...531:
                    return "cloud.rain"
                case 600...622:
                    return "cloud.snow"
                case 701...781:
                    return "cloud.fog"
                case 800:
                    return "sun.max"
                case 801...804:
                    return "cloud.bolt"
                default:
                    return "cloud"
                }
    }
    
}


struct CountryModel {
    let country : String
    let localtime : String
    let icon : String
}

struct LocationforSearch {
    let cityName : String
    let lat : Double
    let lon : Double
    
    init(city : String, latitude : Double, longitude : Double) {
        self.cityName = city
        self.lat = latitude
        self.lon = longitude
    }
}


