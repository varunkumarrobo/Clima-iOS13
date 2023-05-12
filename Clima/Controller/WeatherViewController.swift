
import UIKit
import CoreLocation
import CoreData

protocol WeatherViewControllerDelegate : AnyObject {
    func didTapMenuButton()
}

class WeatherViewController: UIViewController{
    
    var  itemArray = [ WeatherDB ] ()
    var favoriteItems: [WeatherDB] = []
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var leading: NSLayoutConstraint!
    @IBOutlet var trailing: NSLayoutConstraint!
    @IBOutlet var backgroundLeading: NSLayoutConstraint!
    @IBOutlet var backGroundTrailing: NSLayoutConstraint!
    @IBOutlet var segmentedButtonControl: UISegmentedControl!
    @IBOutlet var minMaxLabel: UILabel!
    @IBOutlet var visibilityLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var feelsLikeLabel: UILabel!
    @IBOutlet var countryLabelSec: UILabel!
    
    var countryLabel = ""
    
    var isFavourite = false
    var fahrenheitTemp = 0.0
    
    var drawerViewCopy = UIView()
    var drawerBackgroundView = UIView()
    var drawerStatus = false
    
    var homeButton = UIButton()
    var favouriteButton = UIButton()
    var recentButton = UIButton()
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var secondVC = SecondVC()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("WeatherDB.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFilePath!)
        
        weatherManager.delegate = self
        weatherManager.delegateSec = self
        
        secondVC.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        saveItems()
        loadFavoriteItems()
        loadDrawerBackground()
        drawerViewCopy.layer.zPosition = 1
        loadDrawer()
        segmentedControl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDrawerUI()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        drawerStatus = false
        updateDrawerUI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        
    }
    
    func loadFavoriteItems() {
        let request: NSFetchRequest<WeatherDB> = WeatherDB.fetchRequest()
        do {
            favoriteItems = try context.fetch(request)
            print("Excuted at loadFavoriteItems")
        } catch {
            print("Error loading favorite items: \(error)")
        }
    }
    //MARK: - DataBase Related Functions
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
    }
    
    //MARK:- SegmentedControl part
    
    @IBAction func segmentedOutput(_ sender: UISegmentedControl) {
        
        let celsiusTemp = (fahrenheitTemp - 32) * 5/9
        print(celsiusTemp)
        if segmentedButtonControl.selectedSegmentIndex == 0 {
            temperatureLabel.text = String(format: "%.0f", celsiusTemp)
        } else {
            temperatureLabel.text = String(format: "%.0f", fahrenheitTemp)
        }
    }
    
    func segmentedControl()  {
        segmentedButtonControl.backgroundColor = .clear
        segmentedButtonControl.tintColor = .clear
        segmentedButtonControl.layer.borderColor = UIColor.white.cgColor
        segmentedButtonControl.layer.cornerRadius = 0
        segmentedButtonControl.layer.borderWidth = 2
        segmentedButtonControl.backgroundColor = .clear
        segmentedButtonControl.setTitleTextAttributes([
                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
                                                        NSAttributedString.Key.foregroundColor: UIColor(named: "#E32843") ?? .red], for: .selected)
        segmentedButtonControl.setTitleTextAttributes([
                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
                                                        NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    }
    
    
    //MARK: - UI Desgin Related Functions
    
    
    func updateDrawerUI() {
        UIView.animate(withDuration: 0.75) {
            self.drawerViewCopy.frame.origin.x = self.drawerStatus ? 0 : -self.drawerViewCopy.frame.width
            self.drawerBackgroundView.alpha = self.drawerStatus ? 0.6: 0
            print("animation complete")
        }
    }
    
    @objc func handleBackgroundTap() {
        drawerStatus = false
        updateDrawerUI()
    }
    
    @objc func homeButtonTapped() { print("homeButtonTapped") }
    @objc func favouriteButtonTapped() {
        performSegue(withIdentifier: "goToFavourties", sender: navigationController)
        print("favouriteButtonTapped") }
    @objc func recentButtonTapped() { print("recentButtonTapped") }
    
    //MARK: - Button's Related Functions
    @IBAction func addToFav(_ sender: UIButton) {
        
        let newItem = WeatherDB(context: self.context)
        newItem.place = cityLabel.text ?? "Udupi"
        newItem.country = countryLabelSec.text ?? "India"
        
        isFavourite = !isFavourite
        if isFavourite {
            // Item already exists, delete it
            sender.setTitle("Add to favourite", for: .normal)
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            if let index = favoriteItems.lastIndex(of: newItem) {
                favoriteItems.remove(at: index)
                itemArray.remove(at: index)
                context.delete(itemArray.last!)
            }
            context.delete(newItem)
            saveItems()
            print("Item removed from favorites")
        } else {
            // Item doesn't exist, add it
            sender.setTitle("Remove from favourite", for: .normal)
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            
            favoriteItems.append(newItem)
            saveItems()
            print("Item added to favorites")
        }
        
        //        isFavourite.toggle()
        //        if favoriteItems.contains(newItem) {
        //                // Item already exists, delete it
        //                sender.setTitle("Add to favorites", for: .normal)
        //                sender.setImage(UIImage(systemName: "heart"), for: .normal)
        //                if let index = favoriteItems.firstIndex(of: newItem) {
        //                    favoriteItems.remove(at: index)
        //                }
        //                context.delete(newItem)
        //                saveItems()
        //                print("Item removed from favorites")
        //            } else {
        //                // Item doesn't exist, add it
        //                sender.setTitle("Remove from favorites", for: .normal)
        //                sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        //                favoriteItems.append(newItem)
        //                saveItems()
        //                print("Item added to favorites")
        //            }
        
        //        func addFavorite() {
        //            // Execute an SQL INSERT statement to add the item as a favorite
        //            sender.setTitle("Remove from favourite", for: .normal)
        //            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        //            if let index = favoriteItems.firstIndex(of: newItem) {
        //                        favoriteItems.remove(at: index)
        //                    }
        //            self.itemArray.append(newItem)
        //            self.saveItems()
        //            print("Success")
        //            // Execute the SQL statement with your SQLite database connection
        //            // ...
        //        }
        //
        //        func deleteFavorite() {
        //            // Execute an SQL DELETE statement to remove the item from favorites
        //            sender.setTitle("Add to favourite", for: .normal)
        //            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        //            if let lastItem = itemArray.last {
        //                context.delete(lastItem)
        //                self.itemArray.removeLast()
        //            }
        //            print("Deleted")
        //            // Execute the SQL statement with your SQLite database connection
        //            // ...
        //        }
        //
        //        func checkIfFavorite() -> Bool {
        //            // Execute an SQL SELECT statement to check if the item is already a favorite
        //            if itemArray.contains(newItem) {
        //                return true
        //            } else {
        //                return false
        //            }
        //            // Execute the SQL statement with your SQLite database connection
        //            // ...
        //            // Check the result of the SELECT query to determine if the item is a favorite
        //            // Return true if the item is a favorite, false otherwise
        //        }
        //
        //        isFavourite.toggle()
        //
        //        if isFavourite {
        //            sender.setTitle("Remove from favourite", for: .normal)
        //            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        //            deleteFavorite()
        //            print("Deleted")
        //        } else {
        //            sender.setTitle("Add to favourite", for: .normal)
        //            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        //            addFavorite()
        //            print("Success")
        //        }
        
        //        let isFavorite = checkIfFavorite()
        //          isFavorite ? deleteFavorite() : addFavorite()
        
        //        if cityLabel.text == "" {
        //            print("empty")
        //        } else {
        //            self.itemArray.append(newItem)
        //        }
        
        //        func deleteFavorite(_ itemId: Array<Any>) {
        //            // Execute an SQL DELETE statement to remove the item from favorites
        //            sender.setTitle("Remove from favourite", for: .normal)
        //            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        //            for i in 0 ..< itemArray.count where i < itemArray.count-1 {
        //                context.delete(itemArray[i])
        //                self.itemArray.removeLast()
        //            }
        //            print("Deleted")
        //            // Execute the SQL statement with your SQLite database connection
        //            // ...
        //        }
        
        //                        isFavourite = !isFavourite
        //                        if isFavourite {
        //                            sender.setTitle("Remove from favourite", for: .normal)
        //                            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        //                            for i in 0 ..< itemArray.count where i < itemArray.count-1 {
        //                                context.delete(itemArray[i])
        //                                itemArray.removeLast()
        //                            }
        //                            print("Deleted")
        //                        } else {
        //                            sender.setTitle("Add to favourite", for: .normal)
        //                            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        //                            self.itemArray.append(newItem)
        //                            print("Sucess")
        //                        }
        
        //        self.saveItems()
        //        print("success")
    }
    
    func didTapMenuButton(){
        print("Pressed")
        drawerStatus = !drawerStatus
        updateDrawerUI()
        print("did tap menu")
    }
    
    @IBAction func drawerButton(_ sender: UIButton) {
        print("drawer Button pressed")
        didTapMenuButton()
    }
    
    
    @IBAction func currentLocation(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goSearchVC", sender: navigationController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondVC = segue.destination as? SecondVC, segue.identifier == "goSearchVC" {
            secondVC.loadViewIfNeeded()
            secondVC.delegate = self
            secondVC.dataName = cityLabel.text ?? "NO Name"
        }
    }
    
    //MARK:- LoadDrawer
    func loadDrawer() {
        view.addSubview(drawerViewCopy)
        drawerViewCopy.backgroundColor = .white
        drawerViewCopy.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawerViewCopy.trailingAnchor.constraint(equalTo: view.leadingAnchor),
            drawerViewCopy.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            drawerViewCopy.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            drawerViewCopy.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        drawerViewCopy.addSubview(homeButton)
        homeButton.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        drawerViewCopy.addSubview(favouriteButton)
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        drawerViewCopy.addSubview(recentButton)
        recentButton.addTarget(self, action: #selector(recentButtonTapped), for: .touchUpInside)
        
        homeButton.setTitle("Home", for: .normal)
        homeButton.tintColor = .black
        homeButton.setTitleColor(.black, for: .normal)
        homeButton.showsTouchWhenHighlighted = true
        
        favouriteButton.setTitle("Favourite", for: .normal)
        favouriteButton.tintColor = .black
        favouriteButton.setTitleColor(.black, for: .normal)
        favouriteButton.showsTouchWhenHighlighted = true
        
        recentButton.setTitle("Recent", for: .normal)
        recentButton.tintColor = .black
        recentButton.setTitleColor(.black, for: .normal)
        homeButton.showsTouchWhenHighlighted = true
        
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        recentButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            homeButton.leadingAnchor.constraint(equalTo: drawerViewCopy.leadingAnchor, constant: 50),
            homeButton.topAnchor.constraint(equalTo: drawerViewCopy.topAnchor, constant: 100),
            favouriteButton.leadingAnchor.constraint(equalTo: homeButton.leadingAnchor),
            favouriteButton.topAnchor.constraint(equalTo: homeButton.topAnchor, constant: 40),
            recentButton.leadingAnchor.constraint(equalTo: favouriteButton.leadingAnchor),
            recentButton.topAnchor.constraint(equalTo: favouriteButton.topAnchor, constant: 40),
        ])
    }
    
    func loadDrawerBackground() {
        view.addSubview(drawerBackgroundView)
        drawerBackgroundView.backgroundColor = .black
        drawerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawerBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            drawerBackgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            drawerBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            drawerBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap));  drawerBackgroundView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
}

//MARK:- FetchWeatherFromSecondVC

extension WeatherViewController : passDataToVC {
    func fetchWeatherFromSecondVC(str: String) {
        weatherManager.fetchWeather(cityName: str)
        weatherManager.fetchWeather(countryName: str)
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
            self.cityLabel.text = "\(weather.cityName),\(self.countryLabel)"
            self.descriptionLabel.text = weather.description
            self.minMaxLabel.text = "\(weather.temp_min) - \(weather.temp_max)"
            self.humidityLabel.text = String(weather.humidity)
            self.feelsLikeLabel.text = String(weather.feels_like)
            self.visibilityLabel.text = String(weather.visibility)
            let formatter = DateFormatter()
            formatter.dateFormat = "E, dd MMM yyyy hh:mm a"
            let currentTimeString = formatter.string(from: Date())
            print(currentTimeString)
            self.timeLabel.text = currentTimeString
            self.fahrenheitTemp = (weather.temp * 9/5) + 32
            print("fahrenheitTemp : -  \(self.fahrenheitTemp)")
            print(weather.timeString)
            print(self.temperatureLabel.text!)
            print(self.descriptionLabel.text!)
        }
    }
    
    func didFailError(error: Error) {
        print("error from didUpdateWeather \(error)")
    }
}
//MARK:- CountryDetailsDelegate
extension WeatherViewController : CountryDetailsDelegate {
    
    func didUpdateDetails(_ weatherManager: WeatherManager, details: CountryModel) {
        DispatchQueue.main.async {
            self.countryLabelSec.text = details.country
            print(details.country)
        }
    }
    
    func didFailDetailsError(error: Error) {
        print("error from didUpdateDetails \(error)")
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





//MARK: - Commented Code for some Refernce

//func navBarTrans() {
//    let navBarAppearance = UINavigationBarAppearance()
//    navBarAppearance.configureWithTransparentBackground()
//    navigationController?.navigationBar.standardAppearance = navBarAppearance
//    navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
//}
//
//func addNavBarImage() {
//    let navController = navigationController!
//    let image = UIImage(named: "logo") //Your logo url here
//    let imageView = UIImageView(image: image)
//    let bannerWidth = navController.navigationBar.frame.size.width
//    let bannerHeight = navController.navigationBar.frame.size.height
//    let bannerX = bannerWidth / 3 - (image?.size.width)! / 4
//    let bannerY = bannerHeight / 2 - (image?.size.height)! / 3
//    imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
//    imageView.contentMode = .scaleAspectFit
//    navigationItem.titleView = imageView
//}



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

//    private func configureItems() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: UIImage(
//                systemName:  "text.justify"),
//            style: .done,
//            target: self,
//            action: nil
//        )
//    }

//    func fetchWeatherFromSecondVC(city:String) {
//        weatherManager.fetchWeather(cityName: city)
//    }

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


//MARK:- CollectionView
//extension WeatherViewController : UICollectionViewDelegate , UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 20
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! MyCollectionCell
//
//        cell.imageView.image = UIImage(systemName: "thermometer")
//        cell.labelOne.text = "20.25"
//        cell.labelTwo.text = "14.57"
//
//        return cell
//    }
//
//
//    }

//        if menuOut == false {
//            leading.constant = -250
//            trailing.constant = 250
//            //            backgroundLeading.constant = 200
//            //            backGroundTrailing.constant = -200
//            drawerView.isHidden = false
//            menuOut = true
//        } else {
//            leading.constant = 0
//            trailing.constant = 0
//            //            backgroundLeading.constant = 0
//            //            backGroundTrailing.constant = 0
//            drawerView.isHidden = true
//            menuOut = false
//        }

//        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) {
//            self.view.layoutIfNeeded()
//        } completion: { (animationComplete) in
//            print("animation complete")
//        }
