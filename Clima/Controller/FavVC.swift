//
//  FavVC.swift
//  Clima
//
//  Created by Varun Kumar on 22/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData



class FavVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var citiesAdded: UILabel!
    @IBOutlet var numberOfCitisView: UIStackView!
    @IBOutlet var toShowNothing: UIImageView!
    @IBOutlet var toShowNothinglabel: UILabel!
    
    var weatherManager = WeatherManager()
    
    var imageString = ""
    var tempString = ""
    var descripString = ""
    
    var  itemArray = [ WeatherDB ] ()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        title = "Favorites"
        loadItems()
        for i in 0 ..< itemArray.count {
            weatherManager.fetchWeather(cityName: itemArray[i].place ?? "London")
        }
        tableView.dataSource = self
        tableView.delegate = self
        updateCities()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor.clear
        tableView.backgroundView = nil
        
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.systemBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        emptyView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.backgroundColor = UIColor.clear
//        toShowNothing.isHidden = false
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
            citiesAdded.text =      "\(itemArray.count) City added as favourite"
        }
        if itemArray.count > 1 {
            citiesAdded.text =   "\(itemArray.count) Citie's added as favourite"
        }
    }
    
    @IBAction func removeAll(_ sender: UIButton) {
        
        for i in 0 ..< itemArray.count where i < itemArray.count-0 {
            context.delete(itemArray[i])
        }
        
        itemArray.removeAll()
        saveItems()
        updateCities()
        
    }
    
  
    @IBAction func deleteFavs(_ sender: UIButton) {
        
    }
    
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
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        
        self.tableView.reloadData()
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
        
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let favDetails = itemArray[indexPath.row]
        
        
        let image = imageString
        let temp = tempString
        let desc = descripString
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
        
        //        let cell = tableView.cellForRow(at: indexPath) as! Cell
        cell.setNames(itemArray: favDetails)
        
        cell.favImaLabel.image = UIImage(systemName: image)
        cell.tempLabel.text = temp
        cell.descripLabel.text = desc
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        print(tempString)
        print(descripString)
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


//        cell.cityLabel.text = itemArray[indexPath.row].place
//        cell.countryLabel.text = itemArray[indexPath.row].country

//        cell.textLabel?.text = itemArray[indexPath.row].place
//        cell.detailTextLabel?.text = itemArray[indexPath.row].country

//        cell.imageView?.image = UIImage(systemName: "heart.fill")

