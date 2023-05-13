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
    
    var isFavourtie : Bool!
    
    
    var weatherManager = WeatherManager()
    var imageString = ""
    var tempString = ""
    var descripString = ""
    
    var  itemArray : [WeatherDB] = []
    var recentSearch : [RecentSearch] = []
    
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
        updateCities()
        tableViewSetUp()
        emptyView()
        loadRecent()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //        tableView.backgroundColor = UIColor.clear
        //        toShowNothing.isHidden = false
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
    
    @IBAction func deleteFavs(_ sender: UIButton) {
        
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
extension FavVC : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFavourtie ? itemArray.count  : recentSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        
        let image = imageString
        let temp = tempString
        let desc = descripString
        
        if isFavourtie {
            let favoriteItem = itemArray[indexPath.row]
                    cell.setNames(itemArray: favoriteItem)
                    // Configure the cell using favoriteItem properties
                } else {
                    let recentSearchItem = recentSearch[indexPath.row]
                    cell.setSearchs(searchArray: recentSearchItem)
                    // Configure the cell using recentSearchItem properties
                }
        
        cell.favImaLabel.image = UIImage(systemName: image)
        cell.tempLabel.text = temp
        cell.descripLabel.text = desc
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
    
}

        

        //        let cell = tableView.cellForRow(at: indexPath) as! Cell

        
//        // Separator index
//                let separatorIndex = isFavourtie ? itemArray.count - 1 : recentSearch.count - 1
//                if indexPath.row == separatorIndex {
//                    isFavourtie ? cell.setNames(itemArray: favDetails) : cell.setSearchs(searchArray:  serachDetails)
//                    cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
//                } else {
//                    cell.separatorInset = UIEdgeInsets.zero
//                }
//        print(tempString)
//        print(descripString)

