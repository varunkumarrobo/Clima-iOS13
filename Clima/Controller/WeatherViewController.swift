
import UIKit
import CoreLocation
import CoreData

protocol WeatherViewControllerDelegate : AnyObject {
    func didTapMenuButton()
}

class WeatherViewController: UIViewController{
    
    var  itemArray = [ WeatherDB ] ()
    var favoriteItems: [WeatherDB] = []
    var recentArray = [ RecentSearch ] ()
    
    
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
    @IBOutlet weak var addToFav: UIButton!
    
    
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
        
        addToFav.addTarget(self, action: #selector(addToFav(_:)), for: .touchUpInside)
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
    
    //MARK: - DataBase Related Functions
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
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
    
    //MARK: - SegmentedControl part
    
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
        segmentedButtonControl.apportionsSegmentWidthsByContent = true
        segmentedButtonControl.backgroundColor = .clear
        segmentedButtonControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor(named: "#E32843") ?? .red
        ], for: .selected)
        segmentedButtonControl.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)
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
    
    
    
    
    //MARK: - Button's Related Functions
    @IBAction func addToFav(_ sender: UIButton) {
        
        let newItem = WeatherDB(context: self.context)
        newItem.place = cityLabel.text!
        newItem.country = countryLabelSec.text!
        
        let existingItem = itemArray.first {
            item in
            return item.place?.lowercased() == newItem.place?.lowercased() && item.country?.lowercased() == newItem.country?.lowercased()
        }
        
        if existingItem == nil {
            itemArray.append(newItem)
            favoriteItems.append(newItem) // Keep favoriteItems in sync with itemArray
            saveItems()
            print("Item added to favorites")
            sender.setTitle("Remove from favourite", for: .normal)
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            if let index = itemArray.firstIndex(where: { $0.place == newItem.place && $0.country == newItem.country }) {
                let itemToRemove = itemArray[index]
                favoriteItems.removeAll { $0.place == newItem.place && $0.country == newItem.country }
                itemArray.remove(at: index)
                context.delete(itemToRemove)
                saveItems()
                print("Item removed from favorites")
            }
            sender.setTitle("Add to favourite", for: .normal)
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    @objc func homeButtonTapped() {
        drawerStatus = false
        updateDrawerUI()
        print("homeButtonTapped") }
    
    @objc func favouriteButtonTapped() {
        performSegue(withIdentifier: "goToFavourties", sender: self)
        print("favouriteButtonTapped")
    }
    
    @objc func recentButtonTapped() {
        performSegue(withIdentifier: "goToRecent", sender: self)
        print("recentButtonTapped")
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
    
    //MARK: - prepare and navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondVC = segue.destination as? SecondVC, segue.identifier == "goSearchVC" {
            secondVC.loadViewIfNeeded()
            secondVC.delegate = self
            secondVC.dataName = cityLabel.text ?? "NO Name"
            secondVC.countryName = countryLabel
        } else if segue.identifier == "goToFavourties" {
            if let destinationVC = segue.destination as? FavVC {
                destinationVC.isFavourtie = true
                print("favourite ")
            }
        } else if segue.identifier == "goToRecent" {
            if let destinationVC = segue.destination as? FavVC {
                destinationVC.isFavourtie = false
                print("Recent Search")
            }
        }
    }
    
    //MARK: - LoadDrawer
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

//MARK: - FetchWeatherFromSecondVC

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
            self.cityLabel.text = "\(weather.cityName)"
            self.descriptionLabel.text = weather.description.capitalized
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

//MARK: - Image from api
//extension WeatherViewController {
//    func load(url: URL) {
//        DispatchQueue.global().async {
//            [weak self] in if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.conditionImageView.image = image
//                    }
//                }
//            }
//        }
//    }
//}

//MARK: - CountryDetailsDelegate
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




