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
    
    var weatherManager = WeatherManager()
    
    var imageString = ""
    var tempString = ""
    var descripString = ""
//    var colors : [UIColor] = []
    
    var  itemArray = [ WeatherDB ] ()
   
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        
        title = "Favorites"
        loadItems()
//        weatherManager.fetchWeather(cityName: itemArray[0].place ?? "London" )

        updateCities()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func updateCities()  {
        citiesAdded.text = "\(itemArray.count) City added as favourite"
    }
    
    @IBAction func removeAll(_ sender: UIButton) {
        
        for i in 0 ..< itemArray.count where i < itemArray.count-0 {
            context.delete(itemArray[i])
        }

        itemArray.removeAll()
        saveItems()
        updateCities()
        
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
//                UIImage(systemName: weather.conditionName)

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
//        let imageName = UIImage(systemName: imageString)
        
        let image = imageString
        let temp = tempString
        let desc = descripString
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! Cell
//            UITableViewCell(style: .default, reuseIdentifier: "Cell") as! Cell
            
        
        cell.setNames(itemArray: favDetails)
        
        cell.favImaLabel.image = UIImage(systemName: image)
        cell.tempLabel.text = temp
        cell.descripLabel.text = desc
        weatherManager.fetchWeather(cityName: favDetails.place!)
//        cell.setDetails(temp: tempString, descrip: descripString)
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

