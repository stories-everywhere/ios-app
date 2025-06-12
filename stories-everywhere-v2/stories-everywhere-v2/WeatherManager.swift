//
//  WeatherManager.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 12/06/2025.
// Modified from https://medium.com/@kyang3200/ios-and-swift-weather-app-a9d628171877
import Foundation
import CoreLocation

class WeatherManager {
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody{
        let weatherApiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(weatherApiKey)"
        guard let url = URL(string: weatherApiUrl)
        else { fatalError("Missing URL") }
        print(weatherApiUrl)
        
        
        let urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            let statusCode = httpResponse.statusCode
            let reason = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            throw NSError(
                domain: "WeatherAPI",
                code: statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Weather API request failed with status code \(statusCode): \(reason)"]
            )
        }

        
        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        return decodedData
    }
}
struct ResponseBody: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse
struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }
struct WeatherResponse: Decodable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }
struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }
struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }
}
extension ResponseBody.MainResponse {
    var feelsLike: Double { return feels_like }
    var tempMin: Double { return temp_min }
    var tempMax: Double { return temp_max }
}


