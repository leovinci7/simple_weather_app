//
//  WeatherModel.swift
//  FaireWeather
//
//  Created by Medhad Ashraf Islam on 3/12/22.
//

import Foundation



public struct WeatherModel:Codable{
    
    
    let consolidated_weather:[WeatherDetail]?
    let time:String?
    let title:String?
    let test:String?
    
    struct WeatherDetail:Codable{
        let weather_state_name:String?
        let weather_state_abbr:String?
        let applicable_date:String?
        let min_temp:Double?
        let max_temp:Double?
        let the_temp:Double?
    }
    
}
