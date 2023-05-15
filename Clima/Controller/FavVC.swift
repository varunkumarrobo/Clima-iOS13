//
//  FavVC.swift
//  Clima
//
//  Created by Varun Kumar on 22/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class FavVC : UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var citiesAdded: UILabel!
    @IBOutlet var numberOfCitisView: UIStackView!
    @IBOutlet var toShowNothing: UIImageView!
    @IBOutlet var toShowNothinglabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var removeButtonText: UIButton!
    @IBOutlet var searchFavAndRecent: UITextField!
    @IBOutlet var favSearchButton: UIButton!
    
    
    
    var isFavourtie : Bool!
    
    var weatherManager = WeatherManager()
    var imageString = ""
    var tempString = ""
    var descripString = ""
    
    var  itemArray : [WeatherDB] = []
    var filteredItems = [String]()
    var recentSearch : [RecentSearch] = []
    var filteredRecents = [String]()
    var searching = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        titleLabel.text = isFavourtie ? "Favourties" : "Recent Search"
        loadItems()
        for i in 0 ..< itemArray.count {
            weatherManager.fetchWeather(cityName: itemArray[i].place ?? "London")
        }
        tableView.dataSource = self
        tableView.delegate = self
        searchFavAndRecent.delegate = self
        updateCities()
        tableViewSetUp()
//        emptyView()
        loadRecent()
        searchFavAndRecent.isHidden = true
        searchFavAndRecent.addTarget(self, action: #selector(searchRecord), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchFavAndRecent.borderStyle = .none
        searchFavAndRecent.layer.borderWidth = 0.0
        searchFavAndRecent.layer.borderColor = UIColor.clear.cgColor
    }
    
//    @objc func searchRecord() {
//        if isFavourtie {
//            self.filteredItems.removeAll()
//            let searchData: String = searchFavAndRecent.text?.lowercased() ?? ""
//
//            if searchData.isEmpty {
//                searching = false
//                filteredItems = itemArray.map { $0.place ?? "" }
//            } else {
//                searching = true
//                filteredItems = itemArray.compactMap { $0.place?.lowercased().contains(searchData) ?? false ? $0.place : nil }
//            }
//        } else {
//            self.filteredRecents.removeAll()
//            let searchData: String = searchFavAndRecent.text?.lowercased() ?? ""
//
//            if searchData.isEmpty {
//                searching = false
//                filteredRecents = recentSearch.map { $0.searchPlace ?? "" }
//            } else {
//                searching = true
//                filteredRecents = recentSearch.compactMap { $0.searchPlace?.lowercased().contains(searchData) ?? false ? $0.searchPlace : nil }
//            }
//        }
//
//        tableView.reloadData()
//    }
    
    @objc func searchRecord() {

        if isFavourtie {
            self.filteredItems.removeAll()
            let searchData : Int = searchFavAndRecent.text!.count
            if searchData != 0
            {
                searching = true
                for items in itemArray
                {
                    if let itemToSearch = searchFavAndRecent.text
                    {
                        let range = items.place?.lowercased().range(of: itemToSearch, options: .caseInsensitive, range: nil, locale: nil)
                        if range != nil
                        {
                            if let place = items.place {
                                self.filteredItems.append(place)
                            }
                        }
                    }
                }
            } else {
                for items in itemArray {
                    if let place = items.place {
                        self.filteredItems.append(place)
                    }
                }
                searching = false
            }
            tableView.reloadData()
        } else {
            self.filteredRecents.removeAll()
            let searchData: Int = searchFavAndRecent.text!.count
            if searchData != 0 {
                searching = true
                for items in recentSearch {
                    if let itemToSearch = searchFavAndRecent.text {
                        let range = items.searchPlace?.lowercased().range(of: itemToSearch, options: .caseInsensitive, range: nil, locale: nil)
                        if range != nil {
                            if let place = items.searchPlace {
                                self.filteredRecents.append(place)
                            }
                        }
                    }
                }
            } else {
                for items in recentSearch {
                    if let place = items.searchPlace {
                        self.filteredRecents.append(place)
                    }
                }
                searching = false
            }
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeButtonText.setTitle(isFavourtie ? "Remove All" : "Clear All", for: .normal)
    }
    
    func tableViewSetUp() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.systemBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func emptyView()  {
        if itemArray.count == 0 {
            tableView.isHidden = true
            numberOfCitisView.isHidden = true
            //            toShowNothing.isHidden = false
            //            toShowNothinglabel.isHidden = false
        } else if itemArray.count > 0 {
            //            toShowNothing.isHidden = false
            tableView.isHidden = false
            numberOfCitisView.isHidden = false
        }
    }
    
    
    
    @IBAction func favSearchButton(_ sender: UIButton) {
        
        let isButtonOpen = sender.isSelected
        
        // Toggle the button state
        sender.isSelected = !isButtonOpen
        
        //        sender.isButtonOpen = !sender.isButtonOpen
        
        searchFavAndRecent.isHidden = isButtonOpen ? true : false
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func updateCities()  {
        citiesAdded.text = ""
        if itemArray.count == 1 {
            citiesAdded.text =  isFavourtie ? "\(itemArray.count) City added as favourite" : "You recently searched for"
        }
        if itemArray.count > 1 {
            citiesAdded.text = isFavourtie ? "\(itemArray.count) Citie's added as favourite" : "You recently searched for"
        }
    }
    
    @IBAction func removeAll(_ sender: UIButton) {
        
        func remove() {
            for i in 0 ..< itemArray.count  where i < itemArray.count-0 {
                context.delete(itemArray[i])
            }
            
            itemArray.removeAll()
            saveItems()
            //            updateCities()
        }
        
        func clear(){
            for i in 0 ..< recentSearch.count  where i < recentSearch.count-0 {
                context.delete(recentSearch[i])
            }
            recentSearch.removeAll()
            saveItems()
            //            updateCities()
        }
        
        isFavourtie ? remove() : clear()
        
    }
    
    
    //MARK: - Load Items From DataBase
    
    func loadItems(with request : NSFetchRequest<WeatherDB> =  WeatherDB.fetchRequest() ) {
        
        do{
            itemArray = try context.fetch(request)
            //                print(itemArray[0].place!)
            //                print(itemArray[0].country!)
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadRecent(with request : NSFetchRequest<RecentSearch> =  RecentSearch.fetchRequest())  {
        
        do{
            recentSearch = try context.fetch(request)
            //            print(recentSearch[0].searchPlace!)
            //                print(itemArray[0].country!)
            
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        self.tableView.reloadData()
    }
    
}

//MARK:- FetchWeatherFromSearchVC

extension FavVC : passDataToVC {
    func fetchWeatherFromSecondVC(str: String) {
        weatherManager.fetchWeather(cityName: str)
        weatherManager.fetchWeather(countryName: str)
        print("Updated")
    }
}

//MARK: - WeatherManagerDelegate
extension FavVC : WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel)  {
        DispatchQueue.main.async {
            print("fav-executed")
            self.tempString = weather.tempratureString
            self.imageString = weather.conditionName
            self.descripString = weather.description
            print(self.tempString)
            print(self.descripString)
        }
    }
    
    func didFailError(error: Error) {
        print("edfgoyuregerp \(error)")
    }
}


//MARK: - UITableViewDataSource, UITableViewDelegate
extension FavVC : UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return isFavourtie ? filteredItems.count  : filteredRecents.count
        } else {
            return isFavourtie ? itemArray.count  : recentSearch.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        
        let image = imageString
        let temp = tempString
        let desc = descripString
        
        if searching {
            if isFavourtie {
                let favoriteItem = filteredItems[indexPath.row]
                cell.cityLabel.text = favoriteItem
                cell.favImaLabel.image = UIImage(systemName: image)
                cell.tempLabel.text = temp
                cell.descripLabel.text = desc
                // Configure the cell using favoriteItem properties
            } else {
                let recentSearchItem = filteredRecents[indexPath.row]
                cell.cityLabel.text = recentSearchItem
                cell.favImaLabel.image = UIImage(systemName: image)
                cell.tempLabel.text = temp
                cell.descripLabel.text = desc
                cell.favImageView.image = isFavourtie ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                // Configure the cell using recentSearchItem properties
            }
        } else {
            if isFavourtie {
                let favoriteItem = itemArray[indexPath.row]
                cell.setNames(itemArray: favoriteItem)
                cell.favImaLabel.image = UIImage(systemName: image)
                cell.tempLabel.text = temp
                cell.descripLabel.text = desc
                // Configure the cell using favoriteItem properties
            } else {
                let recentSearchItem = recentSearch[indexPath.row]
                cell.setSearchs(searchArray: recentSearchItem)
                cell.favImaLabel.image = UIImage(systemName: image)
                cell.tempLabel.text = temp
                cell.descripLabel.text = desc
                cell.favImageView.image = isFavourtie ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                // Configure the cell using recentSearchItem properties
            }
        }
        
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        context.delete(itemArray[indexPath.item])
        itemArray.remove(at: indexPath.row)
        
        saveItems()
        updateCities()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchFavAndRecent.resignFirstResponder()
        return true
    }
    
}

