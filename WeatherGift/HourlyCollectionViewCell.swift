//
//  HourlyCollectionViewCell.swift
//  WeatherGift
//
//  Created by Lazaro Alvelaez on 10/24/20.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var hourlyLabel: UILabel!
    @IBOutlet weak var hourlyTemperature: UILabel!
    @IBOutlet weak var hourlyIcon: UIImageView!
    
    var hourlyWeather : HourlyWeather! {
        didSet {
            hourlyLabel.text = hourlyWeather.hour
            hourlyTemperature.text = hourlyWeather.hourlyTemperature
            hourlyIcon.image = UIImage(systemName: hourlyWeather.hourlyIcon)
            
        }
        
    }
    
}
