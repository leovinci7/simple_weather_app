//
//  ViewController.swift
//  FaireWeather
//
//  Created by Medhad Ashraf Islam on 2/12/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var currentLocationTitle: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var weatherStateLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var LoadButton: UIButton!
    
    //GET https://cdn.faire.com/static/mobile-take-home/{location_id}.json
    //For Toronto: https://cdn.faire.com/static/mobile-take-home/4418.json
   // GET https://cdn.faire.com/static/mobile-take-home/icons/{weather_state_abbr}.png
   // https://cdn.faire.com/static/mobile-take-home/icons/lc.png
    
//    struct Constants {
//        static let weatherDataURL = "https://cdn.faire.com/static/mobile-take-home"
//        static let weatherDataURLFixedCity = "https://cdn.faire.com/static/mobile-take-home/4418.json"
//        static let weatherStateIconURL = "https://cdn.faire.com/static/mobile-take-home/icons"
//        static let weatherStateIconFixed = "https://cdn.faire.com/static/mobile-take-home/icons/lc.png"
//    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
       // self.LoadButton.titleLabel?.text = "Load"
        self.fetchWeatherInfo()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.LoadButton.titleLabel?.text = "Load"
    }
    
  
    @IBAction func loadButtonAction(_ sender: Any) {
        
        print("Button pressed")
        self.fetchWeatherInfo()
    }
    
    func fetchWeatherInfo(){
        
        WeatherInfoProvider.loadWeatherInfo(){ result in
            switch result {
            case let .success(weatherInfoArray):
//                for weatherInfo in weatherInfoArray {
//                    print(weatherInfo)
//                }
                
                let index = Int.random(in: 0..<6)
                
                DispatchQueue.main.async {
                 
                    self.currentLocationTitle.text = weatherInfoArray[index].location_title
                    self.currentTemperatureLabel.text =  String(format: "%.1f", weatherInfoArray[index].the_temp)+"\u{00B0}"
                    self.weatherStateLabel.text = weatherInfoArray[index].weather_state_name
                    self.minTemperatureLabel.text = String(format: "%.1f", weatherInfoArray[index].min_temp)+"\u{00B0}"
                    self.maxTemperatureLabel.text = String(format: "%.1f", weatherInfoArray[index].max_temp)+"\u{00B0}"
                    
                    self.weatherImageView.image = UIImage(named: "lc")
                    
                }
                self.fetchWeatherIcon(weatherInfoArray[index])
                
            case let .failure(error):
                print(error)
                
            }
            
        }
        
       // URLSession.shared.request(url: Constants.weatherDataURLFixedCity, expecting: [WeatherModel.self]){ result in
       
       /* URLSession.shared.request(
            url: URL(string:Constants.weatherDataURLFixedCity),
            expecting: WeatherModel.self){
            result in
                switch result {
                case .success(let weatherData):
                    DispatchQueue.main.async {
                        self.currentLocationTitle.text = weatherData.title
                        self.currentTemperatureLabel.text =  String(format: "%.1f", weatherData.consolidated_weather![0].the_temp!)+"\u{00B0}"
                        self.weatherStateLabel.text = weatherData.consolidated_weather![0].weather_state_name
                        self.minTemperatureLabel.text = String(format: "%.1f", weatherData.consolidated_weather![0].min_temp!)+"\u{00B0}"
                        self.maxTemperatureLabel.text = String(format: "%.1f", weatherData.consolidated_weather![0].max_temp!)+"\u{00B0}"
                        
                        self.weatherImageView.image = UIImage(named: "lc")
                        print("temperature: "+self.temperatureFormatter(temperatureValue: 21.7))
                    }
                    //print(weatherData.self)
                    
                case .failure(let error):
                    print(error)
                }
            
            } */
        
    }
    
    func fetchWeatherIcon(_ viewModel:WeatherInfoDisplayViewModel){
        
        WeatherInfoProvider.loadForWeatherIcon(viewModel){ result in
            switch result{
            case let .success(data):
                DispatchQueue.main.async {
                    self.weatherImageView.image = UIImage(data: data)
                    print("Image updated successfully")
                }
               
            case let .failure(error):
                print(error)
            }
        
            
        }
    
    }
    
    
    func temperatureFormatter(temperatureValue tempValue:Double) -> String {
        
        let formatter = MeasurementFormatter()
        formatter.locale = Locale(identifier: "en_UK")
        let measurement = Measurement(value: tempValue, unit: UnitTemperature.celsius)
        let temperature = formatter.string(from: measurement)
        print("Printing temperature:", temperature) // 76.1°F
       // print("Printing in celcius:",measurement.converted(to: UnitTemperature.celsius).value
        return temperature
    }
    
    

}


