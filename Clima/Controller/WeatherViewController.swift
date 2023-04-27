//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

protocol WeatherViewControllerDelegate : AnyObject {
    func didTapMenuButton()
}

class WeatherViewController: UIViewController{
    
    enum MenuState {
        case opened
        case closed
    }
    
//    private var menuState : MenuState = .closed
    
    var  itemArray = [ WeatherDB ] ()
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel! 
    @IBOutlet var countryLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var leading: NSLayoutConstraint!
    @IBOutlet var trailing: NSLayoutConstraint!
    @IBOutlet var backgroundLeading: NSLayoutConstraint!
    @IBOutlet var drawerView: UIView!
    @IBOutlet var backGroundTrailing: NSLayoutConstraint!
    var menuOut = false
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var  secondVC = SecondVC()
    let date = Date();
    let dateFormatter = DateFormatter();
//    weak var delegate : WeatherViewControllerDelegate?
//    let menuVC = MenuViewController()
//    let homeVC = HomeViewController()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("WeatherDB.plist")
 
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    var navVC = UINavigationController(rootViewController: WeatherViewController())
     
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath!)
        
//        delegate = self
        weatherManager.delegate = self
        secondVC.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
//        configureItems()
        addNavBarImage()
        navBarTrans()
        drawerView.isHidden = true
        saveItems()
        
//        addChildVCs()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"),
        style: .done, target: self, action: #selector(didTapMenuButton))
        
    
    }
    
//    private func addChildVCs() {
//        addChild(menuVC)
//        view.addSubview(menuVC.view)
//        menuVC.didMove(toParent: self)
//
//        addChild(homeVC)
//        view.addSubview(homeVC.view)
//        homeVC.didMove(toParent: self)
//    }

   
    @objc func didTapMenuButton(){
        if menuOut == false {
            leading.constant = -250
            trailing.constant = 250
//            backgroundLeading.constant = 200
//            backGroundTrailing.constant = -200
            drawerView.isHidden = false
            menuOut = true
        } else {
            leading.constant = 0
            trailing.constant = 0
//            backgroundLeading.constant = 0
//            backGroundTrailing.constant = 0
            drawerView.isHidden = true
            menuOut = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        } completion: { (animationComplete) in
            print("animation complete")
        }

//        delegate?.didTapMenuButton()
//        switch  menuState {
//        case .closed :
//               //open it
//            UIView.animate(
//                withDuration: 0.5,
//                delay: 0,
//                usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
//                options: .curveEaseInOut) {
//                self.view.frame.origin.x = self.view.frame.size.width - 100
//            } completion: { [weak self] (done) in
//                if done {
//                    self?.menuState = .opened
//                }
//            }
//        case .opened :
//            //close it
//            UIView.animate(
//                withDuration: 0.5,
//                delay: 0,
//                usingSpringWithDamping: 0.8, initialSpringVelocity: 0,
//                options: .curveEaseInOut) {
//                self.view.frame.origin.x = 0
//            } completion: { [weak self] (done) in
//                if done {
//                    self?.menuState = .closed
//                }
//            }
//        }
        
        print("did tap menu")
    }
    
    
    func navBarTrans() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
                    
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    func addNavBarImage() {
            let navController = navigationController!
            let image = UIImage(named: "logo") //Your logo url here
            let imageView = UIImageView(image: image)
            let bannerWidth = navController.navigationBar.frame.size.width
            let bannerHeight = navController.navigationBar.frame.size.height
            let bannerX = bannerWidth / 3 - (image?.size.width)! / 4
            let bannerY = bannerHeight / 2 - (image?.size.height)! / 3
            imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        }
    
//    private func configureItems() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: UIImage(
//                systemName:  "text.justify"),
//            style: .done,
//            target: self,
//            action: nil
//        )
//    }
    
    @IBAction func addToFav(_ sender: UIButton) {
        
        let newItem = WeatherDB(context: self.context)
        newItem.place = cityLabel.text ?? "Udupi"
        newItem.country = countryLabel.text ?? "India"
        
        if cityLabel.text == "" {
            print("empty")
        } else {
            self.itemArray.append(newItem)
        }
        self.saveItems()
         print("success")
        
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
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
            self.countryLabel.text = weather.countryCode
            
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


//override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//    self.navigationController?.navigationBar.shadowImage = UIImage()
//    self.navigationController?.navigationBar.isTranslucent = true
//}
//override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//    self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//    self.navigationController?.navigationBar.shadowImage = nil
//    self.navigationController?.navigationBar.isTranslucent = false
//}

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
