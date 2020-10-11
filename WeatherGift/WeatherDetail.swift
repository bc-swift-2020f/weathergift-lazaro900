//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Lazaro Alvelaez on 10/11/20.
//

import Foundation

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
    }
    
    private struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
    }
    
    
    var timezone = ""
    var dt = 0.0
    var description = ""
    var temp = 0.0
    
    
    func getData(completed: @escaping () -> ()) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=imperial&appid=\(APIKeys.weatherKey)"
        
        guard let url = URL(string: urlString) else {
            print("could not create url")
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error  = error {
                print("Error: \(error.localizedDescription)")
            }
            
            do {
                let result = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = result.timezone
                self.description = result.current.weather[0].description
                self.dt = result.current.dt
                print(result)
                self.temp = result.current.temp
                
            } catch {
                print(error.localizedDescription)
                
            }
            completed()
        }
        task.resume()
    }
    
    
    
}
