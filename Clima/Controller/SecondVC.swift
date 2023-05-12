//
//  SecondVC.swift
//  Clima
//
//  Created by Varun Kumar on 17/04/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

protocol passDataToVC {
    func fetchWeatherFromSecondVC(str: String)
}

class SecondVC: UIViewController {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navBarView: UIView!
    
    var weatherManager = WeatherManager()
    var locations = [LocationforSearch]()
    var searchManager = SearchManager()
    var dataName = ""
    var delegate : passDataToVC!
    var suggestions = [String]()
    var searching = false
    

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
}

//MARK:- SearchManagerDelegate
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
        
//        searchTextField.endEditing(true)
//        print(searchTextField.text!)
//
//        return true
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
        }
        
        if let suggestions = searchTextField.text{
                 searchManager.getSuggestions(search: suggestions)
            print("suggestions -> \(suggestions)")
        }
        searchTextField.text = ""
    }
    
}

//MARK:- UITableView
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



/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
}
*/


//    func textFieldDidBeginEditing(_ textField: UITextField) {
//
//      if textField == searchTextField {
//            tableViewSetUp()
//            tableView.delegate = self
//            tableView.dataSource = self
//            tableView.tag = 18
//            tableView.rowHeight = 80
//            view.addSubview(tableView)
//            tableViewAnimated(load: true)
//        }
//    }

//    func tableViewSetUp() {
//        tableView.frame = CGRect(x: 20, y: view.frame.height, width: view.frame.width - 40, height: view.frame.height - 170)
//        tableView.layer.shadowColor = UIColor.white.cgColor
//        tableView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        tableView.layer.shadowOpacity = 1.0
//        tableView.layer.shadowRadius = 2.0
//        tableView.layer.masksToBounds = true
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "selectCountry")
//    }
    
//    func tableViewAnimated(load:Bool) {
//        if load{
//            UIView.animate(withDuration: 0.2) {
//                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
//            }
//        } else {
//            UIView.animate(withDuration: 0.2) {
//                self.tableView.frame = CGRect(x: 20, y: 170, width: self.view.frame.width - 40, height: self.view.frame.height - 170)
//            } completion: { (done) in
//                for subView in self.view.subviews{
//                    if subView.tag == 18 {
//                        subView.removeFromSuperview()
//                    }
//                }
//            }
//
//        }
//    }

//        self.suggestions.removeAll()
//        let searchData : Int = searchTextField.text!.count
//        if searchData != 0 {
//            searching = true
//            for suggest in testArray {
//                if let nameToSearch = searchTextField.text{
//                    let range = suggest.lowercased().range(of: nameToSearch, options: .caseInsensitive, range: nil, locale: nil)
//                    if range != nil {
//                        self.suggestions.append(suggest)
//                    }
//                }
//            }
//        } else {
//            suggestions = testArray
//            searching = false
//        }
//        tableView.reloadData()

//        if searching {
//            cell.textLabel?.text = suggestions[indexPath.row]
//        }else{
//            cell.textLabel?.text = testArray[indexPath.row]
//        }
