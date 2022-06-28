//
//  WeatherManager.swift
//  Clima
//
//  Created by ibrahim ahmedoglu on 12.06.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let Weatherurl = "https://api.openweathermap.org/data/2.5/weather?appid=8de3dbebb2cf20b4db492dac6708f631&units=metric"
    
    func fetchWeather(cityName: String) {
        let UrlString = "\(Weatherurl)&q=\(cityName)"
        performRequest(urlString: UrlString)
        
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let UrlString = "\(Weatherurl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: UrlString)
        
    }
    var delegate: WeatherManagerDelegate?
    
    func performRequest(urlString: String){
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJson(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func parseJson(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let temp  = decodedData.main.temp
            let city = decodedData.name
            let id = decodedData.weather[0].id
            
            let weather = WeatherModel(conditionId: id, temperature: temp, cityName: city)
            return weather
        }
        catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
