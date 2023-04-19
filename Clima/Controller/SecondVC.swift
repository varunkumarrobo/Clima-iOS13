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

class SecondVC: UIViewController  {

    @IBOutlet var searchTextField: UITextField!
    
    var weatherManager = WeatherManager()
    var dataName = ""
    var delegate : passDataToVC!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        searchTextField.text = dataName

    }
    
    @IBAction func backButton(_ sender: UIButton) {
        delegate.fetchWeatherFromSecondVC(str:
                                            dataName)
        navigationController?.popViewController(animated: true)
    }
    
    
}

//MARK: - UITextFieldDelegate
extension SecondVC :  UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
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
//             weatherManager.fetchWeather(cityName: dataName)
            print(dataName)
            delegate.fetchWeatherFromSecondVC(str: dataName)
        }
        searchTextField.text = ""
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
