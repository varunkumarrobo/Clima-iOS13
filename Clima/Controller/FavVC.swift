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
        tableView.dataSource = self
        tableView.delegate = self
        searchFavAndRecent.delegate = self
        
        titleLabel.text = isFavourtie ? "Favourties" : "Recent Search"
        loadItems()
        for i in 0 ..< itemArray.count {
            weatherManager.fetchWeather(cityName: itemArray[i].place ?? "London")
        }
        
        updateCities()
        tableViewSetUp()
        emptyView()
        loadRecent()
        emptyViewForRecent()
        searchFavAndRecent.isHidden = true
        searchFavAndRecent.addTarget(self, action: #selector(searchRecord), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchFavAndRecent.borderStyle = .none
        searchFavAndRecent.layer.borderWidth = 0.0
        searchFavAndRecent.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeButtonText.setTitle(isFavourtie ? "Remove All" : "Clear All", for: .normal)
        updateCities()
    }
    
    //MARK: - search record for local searchs
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
    
    //MARK: - UI View Setups
    func tableViewSetUp() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = nil
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.systemBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    func emptyView()  {
        
        if isFavourtie {
            if itemArray.count == 0 {
                // Show view for favorites
                let favoritesView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                favoritesView.backgroundColor = UIColor.clear
                favoritesView.center = self.view.center // Position the favoritesView in the center of the background view
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                imageView.image = UIImage(named: "icon_nothing.png") // Replace "your_image_name" with the actual image name
                imageView.contentMode = .scaleAspectFit
                imageView.center = CGPoint(x: favoritesView.bounds.midX, y: favoritesView.bounds.midY - 20) // Adjust the position of the image
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
                label.text = "No Favourties added"
                label.textAlignment = .center
                label.textColor = UIColor.white
                label.center = CGPoint(x: favoritesView.bounds.midX, y: favoritesView.bounds.midY + 50) // Adjust the position of the label
                
                favoritesView.addSubview(imageView)
                favoritesView.addSubview(label)
                
                // Present the favoritesView
                self.view.addSubview(favoritesView)
                
                // Hide other views if necessary
                tableView.isHidden = true
                numberOfCitisView.isHidden = true
            } else {
                // Show the table view and other views
                tableView.isHidden = false
                numberOfCitisView.isHidden = false
            }
        }
        //        else {
        //                if recentSearch.count > 0 {
        //                    // Show view for recent searches
        //                    let recentSearchesView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        //                    recentSearchesView.backgroundColor = UIColor.lightGray
        //                    recentSearchesView.center = self.view.center // Position the recentSearchesView in the center of the background view
        //
        //                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        //                    label.text = "View for recent searches"
        //                    label.textAlignment = .center
        //                    label.center = CGPoint(x: recentSearchesView.bounds.midX, y: recentSearchesView.bounds.midY)
        //                    recentSearchesView.addSubview(label)
        //
        //                    // Present the recentSearchesView
        //                    self.view.addSubview(recentSearchesView)
        //
        //                    // Hide other views if necessary
        //                    tableView.isHidden = true
        //                    numberOfCitisView.isHidden = true
        //                } else {
        //                    // Show the table view and other views
        //                    tableView.isHidden = false
        //                    numberOfCitisView.isHidden = false
        //                }
        //            }
    }
    
    func emptyViewForRecent() {
        if !isFavourtie {
            if recentSearch.count == 0 {
                
                let recentSearchesView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                recentSearchesView.backgroundColor = UIColor.clear
                recentSearchesView.center = self.view.center // Position the recentSearchesView in the center of the background view
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                imageView.image = UIImage(named: "icon_nothing.png") // Replace "your_image_name" with the actual image name
                imageView.contentMode = .scaleAspectFit
                imageView.center = CGPoint(x: recentSearchesView.bounds.midX, y: recentSearchesView.bounds.midY - 20) // Adjust the position of the image
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
                label.text = "No Recent Search"
                label.textAlignment = .center
                label.textColor = UIColor.white
                label.center = CGPoint(x: recentSearchesView.bounds.midX, y: recentSearchesView.bounds.midY + 50) // Adjust the position of the label
                
                recentSearchesView.addSubview(imageView)
                recentSearchesView.addSubview(label)
                
                // Present the recentSearchesView
                self.view.addSubview(recentSearchesView)
                
                
                // Hide other views if necessary
                tableView.isHidden = true
                numberOfCitisView.isHidden = true
            } else {
                // Show the table view and other views
                tableView.isHidden = false
                numberOfCitisView.isHidden = false
            }
        }
    }
    
    func updateCities()  {
        citiesAdded.text = ""
        if itemArray.count == 1 || recentSearch.count == 1 {
            citiesAdded.text =  isFavourtie ? "\(itemArray.count) City added as favourite" : "You recently searched for"
        }
        if itemArray.count > 1 || recentSearch.count > 1 {
            citiesAdded.text = isFavourtie ? "\(itemArray.count) Citie's added as favourite" : " You recently searched for"
        }
    }
    
    //MARK: - Button Related functions
    @IBAction func favSearchButton(_ sender: UIButton) {
        
        let isButtonOpen = sender.isSelected
        
        // Toggle the button state
        sender.isSelected = !isButtonOpen
        
        sender.setBackgroundImage(isButtonOpen ? UIImage(systemName: "magnifyingglass") : UIImage(systemName: "xmark"), for: .normal)
        
        searchFavAndRecent.isHidden = isButtonOpen ? true : false
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func removeAll(_ sender: UIButton) {
        
        let alert = UIAlertController(title: isFavourtie ? "Are you sure you want to remove all the favourites?" : "Are you sure you want to clear all the recent searches?", message: "", preferredStyle: .alert)

        let noAction = UIAlertAction(title: "No", style: .default) { (action) in
            self.dismiss(animated: true)
            print("No action tapped")
            // Perform any additional actions or UI updates when "No" is tapped
        }

        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            if self.isFavourtie {
                for i in 0 ..< self.itemArray.count where i < self.itemArray.count - 0 {
                    self.context.delete(self.itemArray[i])
                }
                self.itemArray.removeAll()
            } else {
                for i in 0 ..< self.recentSearch.count where i < self.recentSearch.count - 0 {
                    self.context.delete(self.recentSearch[i])
                }
                self.recentSearch.removeAll()
            }
            self.saveItems()
            self.dismiss(animated: true)
            print("Yes action tapped")
            // Perform any additional actions or UI updates after removing or clearing the data
        }

        alert.addAction(noAction)
        alert.addAction(yesAction)

        present(alert, animated: true, completion: nil)
        
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

//MARK: - FetchWeatherFromSearchVC

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
        
        cell.deleteButtonAction = {
                self.deleteItem(at: indexPath)
            }
        
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    ////        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
    //
    //        context.delete(itemArray[indexPath.item])
    //        itemArray.remove(at: indexPath.row)
    //
    //        saveItems()
    //        updateCities()
    //
    //        tableView.deselectRow(at: indexPath, animated: true)
    //
    //        self.tableView.reloadData()
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchFavAndRecent.resignFirstResponder()
        return true
    }
    
    func deleteItem(at indexPath: IndexPath) {
        
        tableView.beginUpdates()
            
            if isFavourtie {
                if searching {
//                    let favoriteItem = filteredItems[indexPath.row]
//                    context.delete(favoriteItem)
                    filteredItems.remove(at: indexPath.row)
                } else {
                    let favoriteItem = itemArray[indexPath.row]
                    context.delete(favoriteItem)
                    itemArray.remove(at: indexPath.row)
                }
            } else {
                if searching {
                    filteredRecents.remove(at: indexPath.row)
                } else {
                    let recentSearchItem = recentSearch[indexPath.row]
                    context.delete(recentSearchItem)
                    recentSearch.remove(at: indexPath.row)
                }
            }
            
            saveItems() // Save the changes to the database
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
            
            // Reload the table view to update the data source
            tableView.reloadData()
        
    }
    
}

//extension FavVC: CustomTableViewCellDelegate {
//    func customTableViewCell(_ cell: Cell, didTapDeleteAt indexPath: IndexPath) {
//        // Perform the deletion logic here
//        itemArray.remove(at: indexPath.row)
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//    }
//}
