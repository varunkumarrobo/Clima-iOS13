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
    let sys : System
    let visibility : Int

   
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

struct System : Codable {
    let country : String
}

struct DetailsData : Codable {
    let location : Location
}

struct Location : Codable { 
    let country : String
}


//{
//    "location": {
//        "name": "Udupi",
//        "region": "Karnataka",
//        "country": "India",
//        "lat": 13.35,
//        "lon": 74.75,
//        "tz_id": "Asia/Kolkata",
//        "localtime_epoch": 1683790890,
//        "localtime": "2023-05-11 13:11"
//    },
//    "current": {
//        "last_updated_epoch": 1683790200,
//        "last_updated": "2023-05-11 13:00",
//        "temp_c": 34.0,
//        "temp_f": 93.2,
//        "is_day": 1,
//        "condition": {
//            "text": "Partly cloudy",
//            "icon": "//cdn.weatherapi.com/weather/64x64/day/116.png",
//            "code": 1003
//        },
//        "wind_mph": 9.4,
//        "wind_kph": 15.1,
//        "wind_degree": 250,
//        "wind_dir": "WSW",
//        "pressure_mb": 1008.0,
//        "pressure_in": 29.77,
//        "precip_mm": 0.0,
//        "precip_in": 0.0,
//        "humidity": 60,
//        "cloud": 50,
//        "feelslike_c": 43.0,
//        "feelslike_f": 109.4,
//        "vis_km": 6.0,
//        "vis_miles": 3.0,
//        "uv": 9.0,
//        "gust_mph": 12.5,
//        "gust_kph": 20.2
//    }
//}

    
