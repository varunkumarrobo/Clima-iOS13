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

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=e031dcd3ad8b42c64dce6e16089389d6&units=metric"
    
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String) {
        if let city = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
         
                let urlString = "\(weatherUrl)&q=\(city)"
            performRequest(with: urlString)
            }
        
//        let urlString = "\(weatherUrl)&q=\(cityName.trimmingCharacters(in: .whitespaces))"
//        print(urlString)
//        performRequest(with: urlString)s
        
    }
    
    func fetchWeather(latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        print(urlString)
        performRequest(with: urlString)
    }
    
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
                    print("ritik")
                    if let weather = self.parseJSON(safeData) {
                        print("rithik")
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4.task resume
            task.resume()
        }
    }
    
    
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
            let weather = WeatherModel(conditionId: id, cityName: cityname, temp: temp, description: description,icon: icon, time: time)  
            print(weather)
            return weather
        } catch {
            delegate?.didFailError(error: error)
            print(error)
            return nil
        }
    }
     
}
