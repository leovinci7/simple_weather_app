//
//  FaireWeatherTests.swift
//  FaireWeatherTests
//
//  Created by Medhad Ashraf Islam on 3/12/22.
//

import XCTest
@testable import FaireWeather

class WeatherRemoteFeedLoaderTest: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    

    
    func test_load_deliversErrorOnClientError() {
        
        let (sut, client) = makeSUT()
        var capturedErrors = [WeatherRemoteFeedLoader.Error]()
        sut.load{ result in
            switch result{
            case let .failure(error):
                print("failed case")
                capturedErrors.append(error)
            case .success(_):
                print("success case")
            }
        }
            
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
   
        }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            var capturedErrors = [WeatherRemoteFeedLoader.Error]()
            sut.load { result in
                switch result{
                case .success(_):
                    print("Test: within success case")
                case let .failure(error):
                    print("Test: within failure case")
                    capturedErrors.append(error)
                }
                
            }

            client.complete(withStatusCode: code, at: index)
        
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    
    
    
    
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://test_url.com")!) -> (sut: WeatherRemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = WeatherRemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
       
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data:Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
    


    
}
