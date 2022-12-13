//
//  WeatherInfoDisplayViewModel.swift
//  FaireWeather
//
//  Created by Medhad Ashraf Islam on 3/12/22.
//

import Foundation
public struct WeatherInfoDisplayViewModel {
    
    var location_title:String
    var applicable_date:String
    var time:String
    var weather_state_name:String
    var weather_state_abbr:String
    var min_temp:Double
    var max_temp:Double
    var the_temp:Double
    var weather_state_icon_url:String
    var weather_state_icon_data:Data?
    
}

public class WeatherInfoProvider{
    
    struct Constants {
        static let weatherDataURL = "https://cdn.faire.com/static/mobile-take-home"
        static let weatherDataURLFixedCity = "https://cdn.faire.com/static/mobile-take-home/4418.json"
        static let weatherStateIconURL = "https://cdn.faire.com/static/mobile-take-home/icons"
        static let weatherStateIconFixed = "https://cdn.faire.com/static/mobile-take-home/icons/lc.png"
    }
    
    
    public enum ResultForIcon {
        case success(Data)
        case failure(WeatherRemoteFeedLoader.Error)
    }
    
    
    public enum Result {
        case success([WeatherInfoDisplayViewModel])
        case failure(WeatherRemoteFeedLoader.Error)
    }
    
    
    static func loadWeatherInfo(completion: @escaping (Result) -> Void){
        
        let client = WeatherHttpClient()
        guard let url = URL(string: Constants.weatherDataURLFixedCity) else {
            return
        }
        let weatherFeedLoader = WeatherRemoteFeedLoader(url: url, client: client)
        weatherFeedLoader.load(){ result in
            switch result{
            case let .success(weatherModel):
                //print(weatherModel)
                let viewModels = self.mapWeatherModelToWeatherViewModel(weatherModel: weatherModel)
                
                completion(.success(viewModels))
                
            case let .failure(error):
                // print(error)
                completion(.failure(error))
            }
        }
    }
    
    static func loadForWeatherIcon(_ viewModel:WeatherInfoDisplayViewModel, completion: @escaping (ResultForIcon) -> Void){
        
        let client = WeatherHttpClient()
        guard let url = URL(string: Constants.weatherStateIconURL+"/"+viewModel.weather_state_abbr+".png") else {
            return
        }
        let weatherFeedLoader = WeatherRemoteFeedLoader(url: url, client: client)
        weatherFeedLoader.loadWithIconData(){ result in
            switch result{
            case let .success(data):
                completion(.success(data))
                
            case let .failure(error):
                print("printing from WeatherInfoProvider:", error)
                completion(.failure(error))
            }
        }
    }
    
    
    static func mapWeatherModelToWeatherViewModel(weatherModel model:WeatherModel) -> [WeatherInfoDisplayViewModel]{
        var weatherViewModelArray = [WeatherInfoDisplayViewModel]()
        
        for item in model.consolidated_weather!{
            let viewModel = WeatherInfoDisplayViewModel(
                location_title: model.title ?? "",
                applicable_date: item.applicable_date ?? "",
                time: model.time ?? "",
                weather_state_name: item.weather_state_name ?? "",
                weather_state_abbr: item.weather_state_abbr ?? "",
                min_temp: item.min_temp ?? 0,
                max_temp: item.max_temp ?? 0,
                the_temp: item.the_temp ?? 0,
                weather_state_icon_url: Constants.weatherStateIconURL+"/"+(item.weather_state_abbr ?? "")+".png")
            
            weatherViewModelArray.append(viewModel)
            
        }
        
        return weatherViewModelArray
        
    }
    
    
    
}

class WeatherHttpClient:HTTPClient{
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            
        }
        
        task.resume()
        
        
    }
    
    
    
}
