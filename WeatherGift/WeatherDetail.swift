//
//  WeatherDetail.swift
//  WeatherGift
//
//  Created by Lazaro Alvelaez on 10/11/20.
//

import Foundation

struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeather {
    var hour: String
    var hourlyTemperature: String
    var hourlyIcon: String
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter
} ()

private let hourFormatter: DateFormatter = {
    let hourFormatter = DateFormatter()
    hourFormatter.dateFormat = "ha"
    return hourFormatter
} ()

class WeatherDetail: WeatherLocation {
    
    func fileNameForIcon(icon: String) -> String {
        if icon == "01d" {
            return "clear-day"
        } else if icon == "01n" {
            return "clear-night"
        } else if icon == "02d" {
            return "partly-cloudy-day"
        } else if icon == "02n" {
            return "partly-cloudy-night"
        } else if icon == "03d" {
            return "cloudy"
        } else if icon == "03n" {
            return "cloudy"
        } else if icon == "04d" {
            return "cloudy"
        } else if icon == "04n" {
            return "cloudy"
        } else if icon == "09d" {
            return "rain"
        } else if icon == "09n" {
            return "rain"
        } else if icon == "10d" {
            return "rain"
        } else if icon == "10n" {
            return "rain"
        } else if icon == "11d" {
            return "thunderstorm"
        } else if icon == "11n" {
            return "thunderstorm"
        } else if icon == "13d" {
            return "snow"
        } else if icon == "13n" {
            return "snow"
        } else if icon == "50d" {
            return "fog"
        } else {
            return "fog"
        }
    }
    
    private func systemNameFromID(id: Int, icon: String) -> String {
        switch id {
        case 200...299:
            return "cloud.bolt.rain"
        case 300...399:
            return "cloud.drizzle"
        case 500, 501, 520, 521, 531:
            return "cloud.rain"
        case 502, 503, 504, 522:
            return "cloud.heavyrain"
        case 511, 611...616:
            return "sleet"
        case 600...602, 620...622:
            return "snow"
        case 701, 711, 741:
            return "cloud.fog"
        case 721:
            return (icon.hasSuffix("d") ? "sun.haze" : "cloud.fog")
        case 731, 751, 761, 762:
            return (icon.hasSuffix("d") ? "sun.dust" : "cloud.fog")
        case 771:
            return "wind"
        case 781:
            return "tornado"
        case 800:
            return (icon.hasSuffix("d") ? "sun.max" : "moon")
        case 802, 801:
            return (icon.hasSuffix("d") ? "cloud.sun" : "cloud.moon")
        case 803, 804:
            return "fog"

        default:
            return "questionmark.diamond"
        }
    }
    
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    private struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Hourly: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Daily: Codable {
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    struct Temp: Codable {
        var max: Double
        var min: Double
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
        var id: Int
    }
    
    
    var timezone = ""
    var dt = 0.0
    var description = ""
    var temp = 0.0
    var image = ""
    var time = 0
    
    var dailyWeatherData : [DailyWeather] = []
    var hourlyWeatherData : [HourlyWeather] = []
    
    
    
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
                self.image = result.current.weather[0].icon
                for index in 0..<result.daily.count {
                    let weekDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekDate)
                    let dailyIcon1 = self.fileNameForIcon(icon: result.daily[index].weather[0].icon)
                    let dailySummary = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon1, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    self.dailyWeatherData.append(dailyWeather)
                    print("Day: \(dailyWeekday), High: \(dailyHigh), Low: \(dailyLow)")
                }
                
                
                for index in 0..<result.hourly.count {
                    let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let hour = hourFormatter.string(from: hourlyDate)
                    let hourlyIcon = self.systemNameFromID(id: result.hourly[index].weather[0].id, icon: (result.hourly[index].weather[0].icon))
                    let hourlyTemperature = Int(result.hourly[index].temp.rounded())
                    let hourlWeather = HourlyWeather(hour: hour, hourlyTemperature: String(hourlyTemperature), hourlyIcon: hourlyIcon)
                    print("Hour: \(hour), Temperature: \(hourlyTemperature), Icon: \(hourlyIcon)")

                    self.hourlyWeatherData.append(hourlWeather)

                }
                
            } catch {
                print(error.localizedDescription)
                
            }
            completed()
        }
        task.resume()
    }
    
    
    
}
