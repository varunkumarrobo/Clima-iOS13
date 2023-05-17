//
//  SecondVC.swift
//  Clima
//
//  Created by Varun Kumar on 17/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

protocol passDataToVC {
    func fetchWeatherFromSecondVC(str: String)
}

class SecondVC: UIViewController {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navBarView: UIView!
    
    var recentArray = [ RecentSearch ] ()
    var weatherManager = WeatherManager()
    var locations = [LocationforSearch]()
    var searchManager = SearchManager()
    var dataName = ""
    var countryName = ""
    var delegate : passDataToVC!
//    var suggestions = [String]()
    var searching = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
       
        searchTextField.delegate = self
        searchTextField.text = dataName
        tableView.delegate = self
        tableView.dataSource = self
        searchManager.delegate = self
        searchTextField.addTarget(self, action: #selector(searchRecord), for: .editingChanged)
        addTopAndBottomBorders()
        tableView.tableFooterView = UIView(frame: .zero)
        SaveSearch()
    }
    
    
    @objc func searchRecord(sender: UITextField){
        
        let cityName = searchTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if cityName.count > 2 {
            self.searchManager.getSuggestions(search: cityName)
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func addTopAndBottomBorders() {
       let thickness: CGFloat = 2.0
       let bottomBorder = CALayer()
       bottomBorder.frame = CGRect(x:0, y: self.navBarView.frame.size.height - thickness, width: self.navBarView.frame.size.width, height:thickness)
       bottomBorder.backgroundColor = UIColor.gray.cgColor
        navBarView.layer.addSublayer(bottomBorder)
    }
    
//MARK: - Save to DataBase
    
    func SaveSearch() {
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

//MARK: - SearchManagerDelegate
extension SecondVC : SearchManagerDelegate{
    func updateTableView(locationList: [LocationforSearch]) {
        DispatchQueue.main.async{
            [self] in locations = locationList
            tableView.reloadData()
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension SecondVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
            textField.resignFirstResponder()
            let cityName = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            searchManager.getSuggestions(search: cityName)
            return true
        } else {
            return false
        }
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else{
            textField.placeholder = "Type Something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let dataName = searchTextField.text{
            print(dataName)
            delegate.fetchWeatherFromSecondVC(str: dataName)
            weatherManager.fetchWeather(cityName: dataName)
            
        }
        
        //Adding search's to the recentSearchDatabase
        if let suggestions = searchTextField.text{
                 searchManager.getSuggestions(search: suggestions)
            let userEntity = NSEntityDescription.entity(forEntityName: "RecentSearch", in: context)!
            // Check if the item already exists in recentArray
            let searchPlace = "\(String(searchTextField.text ?? "No Name for Search"))"
            let searchCountry = countryName
            let isFav = false
            let existingItems = recentArray.filter {
                item in
                let place = item.value(forKey: "searchPlace") as? String
                let country = item.value(forKey: "searchCountry") as? String
                let fav = item.value(forKey: "isFav") as? Bool
                return place == searchPlace && country == searchCountry && fav == isFav
            }
            if existingItems.isEmpty {
                // Create and add a new item only if it doesn't already exist
                let newUser = NSManagedObject(entity: userEntity, insertInto: context)
                newUser.setValue(searchPlace, forKeyPath: "searchPlace")
                newUser.setValue(searchCountry, forKey: "searchCountry")
                newUser.setValue(isFav, forKey: "isFav")
                recentArray.append(newUser as! RecentSearch)
                self.SaveSearch()
            }
            print("suggestions -> \(suggestions)")
        }
        searchTextField.text = ""
    }
    
}

//MARK: - UITableView
extension SecondVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = locations[indexPath.row].cityName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTextField.text = locations[indexPath.row].cityName
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

