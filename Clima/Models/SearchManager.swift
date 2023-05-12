//
//  SearchManager.swift
//  Clima
//
//  Created by Varun Kumar on 11/05/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

protocol SearchManagerDelegate {
    func updateTableView(locationList: [LocationforSearch])
    
}

struct SearchManager {
    
    let suggestionsUrl = "https://api.foursquare.com/v3/autocomplete?&types=geo"
    
    //    "https://api.foursquare.com/v3/autocomplete?&types=geo&query=Udupi"
    
    var delegate : SearchManagerDelegate!
    
    //MARK: - getSuggestion Function
    func getSuggestions(search : String) {
        
        let textURL = "\(suggestionsUrl)&query=\(search.trimmingCharacters(in: .whitespaces))"
        print(textURL)
        guard let url = URL(string: textURL) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("fsq3/Vr+Nmzkyj7t+yDgqpCXAcL8FRRi/7SPQNG5YsEHmPE=", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        var locationList = [LocationforSearch]()
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in guard let data = data, error == nil
            else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let results = json["results"] as! [[String: Any]]
            for result in results {
                print("result from search \(result)")
                let text = result["text"]! as! [String:Any]
                let name = text["primary"]! as! String
                let geo = result["geo"]! as! [String:Any]
                let center = geo["center"]! as! [String:Double]
                let latitude = center["latitude"]!
                let longitude = center["longitude"]!
                locationList.append(
                    LocationforSearch(city: name, latitude: latitude, longitude: longitude)
                )
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        // print(locationList.count)
        delegate.updateTableView(locationList: locationList)
        
        }
        task.resume()
        
    }
}

