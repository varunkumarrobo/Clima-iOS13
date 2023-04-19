//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController{

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel! 
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var  secondVC = SecondVC()
    let date = Date();
    let dateFormatter = DateFormatter();
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        secondVC.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    
    @IBAction func currentLocation(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goSearchVC", sender: navigationController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let secondVC = segue.destination as? SecondVC, segue.identifier == "goSearchVC" {
                // at this moment secondVC did not load its view yet, trying to access it would cause crash
                // because transferWord tries to set label.text directly, we need to make sure that label
                // is already set (for experiment you can try comment out next line)
                secondVC.loadViewIfNeeded()
                secondVC.delegate = self
                // but here secondVC exist, so lets call transferWord on it
                secondVC.dataName = cityLabel.text ?? "NO Name"
            }
        }
//    func fetchWeatherFromSecondVC(city:String) {
//        weatherManager.fetchWeather(cityName: city)
//    }
}

//MARK:- FetchWeatherFromSecondVC

extension WeatherViewController : passDataToVC {
    func fetchWeatherFromSecondVC(str: String) {
        weatherManager.fetchWeather(cityName: str)
        print("Updated")
    } 
    
}

//MARK: - UITextFieldDelegate
//extension WeatherViewController : UITextFieldDelegate {
//
//    @IBAction func searchButton(_ sender: UIButton) {
//        searchTextField.endEditing(true)
////        performSegue(withIdentifier: "goSearchVC", sender: self)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        searchTextField.endEditing(true)
////        print(searchTextField.text!)
//        return true
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if textField.text != "" {
//            return true
//        } else{
//            textField.placeholder = "Type Something"
//            return false
//        }
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if let city = searchTextField.text{
//            weatherManager.fetchWeather(cityName: city)
//            print(city)
//        }
//        searchTextField.text = ""
//    }
//}

//MARK: - WeatherManagerDelegate
extension WeatherViewController : WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel)  {
        DispatchQueue.main.async {
            print("executed")
            self.temperatureLabel.text = weather.tempratureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
//            self.imageIcon.image = weather.icon     
            self.cityLabel.text = weather.cityName
            self.descriptionLabel.text = weather.description

            let mytime = weather.timeString
            let format = DateFormatter()
            format.timeStyle = .long
            format.dateStyle = .long
            print(format.string(from: mytime))

            self.timeLabel.text =  String(format.string(from: mytime))
            
            print(weather.timeString)
            print(self.temperatureLabel.text!)
            print(self.descriptionLabel.text!)
        }
    }
    
    func didFailError(error: Error) {
        print("edfgoyuregerp \(error)")
    }
}



//MARK: - CLLocationManagerDelegate
extension WeatherViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
