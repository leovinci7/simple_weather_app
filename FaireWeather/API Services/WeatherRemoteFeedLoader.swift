//
//  WeatherFeedLoader.swift
//  FaireWeather
//
//  Created by Medhad Ashraf Islam on 4/12/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class WeatherRemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case requestError
    }
    
    public enum Result{
        case success(WeatherModel)
        case failure(Error)
    }
    
    public enum ResultForIcon {
        case success(Data)
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let item = try WeatherModelMapper.map(data, response)
                    completion(.success(item))
                }catch{
                    completion(.failure(.invalidData))
                }
            case let .failure(error):
                completion(.failure(.connectivity))
                
                
            }
        }
    }
    
    
    public func loadWithIconData(completion: @escaping (ResultForIcon) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                guard response.statusCode == 200 else {
                    completion(.failure(.requestError))
                    return
                }
                    completion(.success(data))
            
            case let .failure(error):
                //print(error)
                completion(.failure(.connectivity))
            }
        }
    }
    
    
}


private class WeatherModelMapper {
   
    static var OK_200: Int { return 200 }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> WeatherModel {
        guard response.statusCode == OK_200 else {
            throw WeatherRemoteFeedLoader.Error.invalidData
        }
        
        let model = try JSONDecoder().decode(WeatherModel.self, from: data)
        return model
    }
}



extension URLSession {
    
    enum CustomError: Error {
        case invalidUrl
        case responseError
        case invalidData
        
    }
    
    func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void){
        
            guard let url = url else {
                completion(.failure(CustomError.invalidUrl))
                return
            }
            
            let task = dataTask(with: url){ data, response, error in
                guard let data = data else {
                    if let error = error {
                    completion(.failure(error))
                    }else{
                        completion(.failure(CustomError.invalidData))
                    }
                    return
                }
                
                
                do{
                    let result = try JSONDecoder().decode(expecting, from: data)
                    completion(.success(result))
                }
                catch {
                    
                    completion(.failure(error))
                    
                }
                
            }
            
            task.resume()
        
    }
    
}

