//
//  LocationDetailViewController.swift
//  WeatherGift
//
//  Created by Lazaro Alvelaez on 10/9/20.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d"
    return dateFormatter
} ()

class LocationDetailViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weatherDetail: WeatherDetail!
    var locationIndex = 0
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearUserInterface()
        updateUserInterface()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if locationIndex == 0 {
            getLocation()
        }
        
    }
    
    
    
    func clearUserInterface() {
        dateLabel.text = ""
        placeLabel.text = ""
        temperatureLabel.text = ""
        summaryLabel.text = ""
        imageView.image = UIImage()
    }
    
    func updateUserInterface() {
        let pageViewController = UIApplication.shared.windows.first?.rootViewController as! PageViewController
        
        let weatherLocation = pageViewController.weatherLocations[locationIndex]
        weatherDetail = WeatherDetail(name: weatherLocation.name , latitude: weatherLocation.latitude, longitude: weatherLocation.longitude)
        
        pageControl.numberOfPages = pageViewController.weatherLocations.count
        pageControl.currentPage = locationIndex
        
        weatherDetail.getData {
            DispatchQueue.main.sync {
                var image2 = self.weatherDetail.fileNameForIcon(icon: self.weatherDetail.image)
                
                dateFormatter.timeZone = TimeZone(identifier: self.weatherDetail.timezone)
                let usabeDate = Date(timeIntervalSince1970: self.weatherDetail.dt)
                self.dateLabel.text = dateFormatter.string(from: usabeDate)
                self.placeLabel.text = self.weatherDetail.name
                self.temperatureLabel.text = String(Int(self.weatherDetail.temp)) + "°"
                self.summaryLabel.text = self.weatherDetail.description
                self.imageView.image = UIImage(named:  image2)
                self.tableView.reloadData()
                self.collectionView.reloadData()

            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showlist" {
            let destination = segue.destination as! LocationListViewController
            let pageViewController = UIApplication.shared.windows.first?.rootViewController as! PageViewController
            destination.weatherLocations = pageViewController.weatherLocations
        }
        
    }

    @IBAction func unwindFromLocationListViewController(segue: UIStoryboardSegue) {
        let source = segue.source as! LocationListViewController
        locationIndex = source.selectedLocationIndex
        let pageViewController = UIApplication.shared.windows.first?.rootViewController as! PageViewController
        pageViewController.weatherLocations = source.weatherLocations
        pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: locationIndex)], direction: .forward, animated: false, completion: nil)
        
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        let pageViewController = UIApplication.shared.windows.first?.rootViewController as! PageViewController
        
        if sender.currentPage < locationIndex {
            pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: sender.currentPage)], direction: .reverse, animated: true, completion: nil)
        } else {
            pageViewController.setViewControllers([pageViewController.createLocationDetailViewController(forPage: sender.currentPage)], direction: .forward, animated: true, completion: nil)

        }
        
    }
    
    
}

extension LocationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDetail.dailyWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DailyTableViewCell
        cell.dailyWeather = weatherDetail.dailyWeatherData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 
    }
    
    
}

extension LocationDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherDetail.hourlyWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let hourlyCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCollectionViewCell
        hourlyCell.hourlyWeather = weatherDetail.hourlyWeatherData[indexPath.row]
        return hourlyCell
    }
    
    
}

extension LocationDetailViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Checking authorization status")
        handleAuthorizationStatus(status: status)
    }
    
    func handleAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location services denied", message: "Location use is being restricted")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' to change privacy settings")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("unkown message of status")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong opening settings")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil )
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last ?? CLLocation()
        print("current location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            var locationName = ""
            if placemarks != nil {
                let placemark = placemarks?.last
                
                locationName = placemark?.name ?? "parts unkown"
            } else {
                print("error retrieving location")
                locationName = "could not find locaition"
            }
            
            print(locationName)
            
            let pageViewController = UIApplication.shared.windows.first?.rootViewController as! PageViewController
            
            pageViewController.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.latitude
            pageViewController.weatherLocations[self.locationIndex].latitude = currentLocation.coordinate.longitude
            pageViewController.weatherLocations[self.locationIndex].name = locationName
            
            self.updateUserInterface()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
