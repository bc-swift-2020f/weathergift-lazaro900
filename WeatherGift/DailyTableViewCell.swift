//
//  DailyTableViewCell.swift
//  WeatherGift
//
//  Created by Lazaro Alvelaez on 10/24/20.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var dailyImageView: UIImageView!
    @IBOutlet weak var dailyWeekdayLabel: UILabel!
    @IBOutlet weak var dailyHighLabel: UILabel!
    @IBOutlet weak var dailyLowLabel: UILabel!
    @IBOutlet weak var dailySummaryLabel: UITextView!
    
    var dailyWeather : DailyWeather! {
        didSet {
            dailyImageView.image = UIImage(named: dailyWeather.dailyIcon)
            dailyWeekdayLabel.text = dailyWeather.dailyWeekday
            dailyHighLabel.text = String(dailyWeather.dailyHigh)
            dailyLowLabel.text = String(dailyWeather.dailyLow)
            dailySummaryLabel.text = dailyWeather.dailySummary
        }
    }
}
