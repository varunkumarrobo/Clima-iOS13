//
//  WeatherManager.swift
//  Clima
//
//  Created by Varun Kumar on 17/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel)
    func didFailError(error : Error)
}

protocol CountryDetailsDelegate {
    func didUpdateDetails(_ weatherManager : WeatherManager, details : CountryModel)
    func didFailDetailsError(error : Error)
}

struct WeatherManager {
    
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=e031dcd3ad8b42c64dce6e16089389d6&units=metric"
    
    let suggestionsUrl = "https://api.foursquare.com/v3/autocomplete&types=geo"
    
    let countryUrl = "https://api.weatherapi.com/v1/current.json?key=5c3bf1f114ef4babb2573540231105&aqi=no"
    
    var delegate : WeatherManagerDelegate?
    var delegateSec : CountryDetailsDelegate?
    
    //MARK:- Weatherfetching Function
    func fetchWeather(cityName : String) {
        if let city = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let urlString = "\(weatherUrl)&q=\(city)"
            performRequest(with: urlString)
        }
    }
    
    func fetchWeather(latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        print(urlString)
        performRequest(with: urlString)
    }
    
    func fetchWeather(countryName : String) {
        if let city = countryName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let urlString = "\(countryUrl)&q=\(city)"
            performRequestOfCountryDetails(with: urlString)
        }
        
    }
    
    //MARK:- URLSESSION DATATASK
    func performRequest(with urlString : String)  {
        //1.Create a URL
        if let url = URL(string: urlString){
            //2.Create a URLSession
            let session = URLSession(configuration: .default)
            //3.Give the session a task
            let task = session.dataTask(with : url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailError(error: error!)
                    return
                }
                if let safeData = data {
                    print("passed at SafeData")
                    if let weather = self.parseJSON(safeData) {
                        print("passed at self.parseJSON")
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4.task resume
            task.resume()
        }
    }
    
    func performRequestOfCountryDetails(with urlString : String)  {
        //1.Create a URL
        if let url = URL(string: urlString){
            //2.Create a URLSession
            let session = URLSession(configuration: .default)
            //3.Give the session a task
            let task = session.dataTask(with : url) { (data, response, error) in
                if error != nil{
                    self.delegateSec?.didFailDetailsError(error: error!)
                    return
                }
                if let safeData = data {
                    print("passed at SafeData of Country Details")
                    if let details = self.parJSON(safeData) {
                        print("passed at self.parJSON")
                        self.delegateSec?.didUpdateDetails(self, details: details)
                    }
                }
            }
            //4.task resume
            task.resume()
        }
    }
    
    //MARK: - JSON PARSING
    func parseJSON(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let cityname = decodedData.name.trimmingCharacters(in: .whitespaces)
            let temp = decodedData.main.temp
            let description = decodedData.weather[0].description
            let icon = decodedData.weather[0].icon
            let time = decodedData.timezone
            print(time)
            let country = decodedData.sys.country
            let humidity = decodedData.main.humidity
            let feelsLike = decodedData.main.feels_like
            let minTemp = decodedData.main.temp_min
            let maxTemp = decodedData.main.temp_max
            let visibility = decodedData.visibility
            let weather = WeatherModel(conditionId: id, cityName: cityname, temp: temp, description: description,icon: icon, time: time, countryCode: country,feels_like : feelsLike, temp_min: minTemp,temp_max: maxTemp,humidity: humidity, visibility: visibility)
            print(weather)
            return weather
        } catch {
            delegate?.didFailError(error: error)
            print(error)
            return nil
        }
    }
    
    func parJSON(_ countryData : Data) -> CountryModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DetailsData.self, from: countryData)
            let countryName = decodedData.location.country
            let localtime = decodedData.location.localtime
            print("passing data in parJSON \(countryName)")
            let details = CountryModel(country: countryName, localtime: localtime)
            return details
        }catch {
            delegateSec?.didFailDetailsError(error: error)
            print(error)
            return nil
        }
        
    }
    
}

//MARK:- Commented Code for some refernce

//            "https://api.foursquare.com/v3/autocomplete?query=\(search)&types=geo"
//        performSugu(with: url)
//        return url
//        if let url = URL(string: url){
//            let session = URLSession(configuration: .default)
//            let task = session.dataTask(with: url) { (data, response, error) in
//                if error != nil {
//                    print("error in suggestion \(String(describing: error))")
//                    return
//                }
//                guard let data = data, let response = response else { return }
//                print("sugges data \(data)")
//                print("response data \(response)")
//            }
//            task.resume()
//        }



//    func performSugu(with suggUrl : String) {
//        if let url = URL(string: suggUrl){
//            let session = URLSession(configuration: .default)
//            let task = session.dataTask(with: url) { (data, response, error) in
//                if error != nil {
//                    print("error in suggestion \(String(describing: error))")
//                    return
//                }
//                guard let data = data, let response = response else { return }
//                print("sugges data \(data)")
//                print("response data \(response)")
//            }
//            task.resume()
//        }
//    }

//    guard let data = data, let response = response else { return }
//        let urlStr = "https://api.foursquare.com/v3/autocomplete?query=\(search)&types=geo"
//        return urlStr

//    Future<Response> getSuggestions(search) {
//        return http.get(
//            Uri.parse(
//                "https://api.foursquare.com/v3/autocomplete?query=${search}&types=geo"),
//            headers: {
//              'Authorization': 'fsq3v9UR8pMBS27YSiEoMbx8W1/t2ZWe8JfNyxCneK0eiVQ=',
//              'accept': 'application/json'
//            });
//      }


//        let url = URL(string: "\(countryUrl)&q=\(countryName)")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        let session = URLSession.shared
//        session.dataTask(with: request) { (data, response, error) in
//            do {
//                if let data = data, let json = try? JSONSerialization.jsonObject(with: data,  options: []) as? [[String:Any]]{
//                    json.forEach({ element in
//                        if let location = element["location"] as? [String:Any]{
//                            print("place from \(location)")
//                        }
//                    })
////                    let location = json["location"]! as! [String:Any]
////                    let country = location["country"]! as! String
////                    print("json data from \(json)")
////                    print("----------")
////                    print(country)
//
//                }
//            }
//
//        }.resume()
