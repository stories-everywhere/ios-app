//
//  WeatherManager.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 12/06/2025.
// Modified from https://medium.com/@kyang3200/ios-and-swift-weather-app-a9d628171877
import Foundation
import CoreLocation
import SwiftUICore

class WeatherManager: ObservableObject {
    @Published var currentWeatherIcon: String = "questionmark.circle.dashed"
    @Published var weather: String = "unrecognisable weather"
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var weatherLoading: Bool = false
    @Published var locationLoading: Bool = false


    
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
    

    func getIcon(weatherGroup: String) -> String {
        var weatherIcon = "questionmark.circle.dashed"
        switch weatherGroup {
        case "Thunderstorm":
            weatherIcon = "cloud.bolt.rain"
            break
        case "Drizzle":
            weatherIcon = "cloud.drizzle"
            break
        case "Rain":
            weatherIcon = "cloud.heavyrain"
            break
        case "Snow":
            weatherIcon = "cloud.snow"
            break
        case "Atmosphere":
            weatherIcon = "questionmark.circle.dashed"
            break
        case "Clear":
            weatherIcon = "sun.max"
            break
        case "Clouds":
            weatherIcon = "cloud.sun"
            break
        
        default:
            weatherIcon = "questionmark.circle.dashed"
        }
        self.currentWeatherIcon = weatherIcon
        return weatherIcon
    }
    
    let locationManager = LocationManager()
    var weatherResponse: ResponseBody?
    

    
    func getLocationWeather() async {
        await MainActor.run {
            self.weatherLoading = true
            self.locationLoading = true
        }

        locationManager.requestLocation()

        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        
        let timeoutSeconds = 5.0
        let pollInterval: UInt64 = 200_000_000 // 0.2 seconds
        let maxAttempts = Int(timeoutSeconds * 1_000_000_000 / Double(pollInterval))
        
        var attempts = 0

        // Retry loop until location loads or timeout
        while locationManager.isLoading && attempts < maxAttempts {
            try? await Task.sleep(nanoseconds: pollInterval)
            attempts += 1
        }

        await MainActor.run {
            self.locationLoading = false
        }

        guard let location = locationManager.location else {
            await MainActor.run {
                self.weather = "unrecognisable weather"
                self.weatherLoading = false
                print("Failed to get location after \(attempts) attempts.")
            }
            return
        }

        await MainActor.run {
            self.currentLocation = location
            print("Got location: \(location.latitude), \(location.longitude)")
        }

        do {
            let response = try await self.getCurrentWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )

            await MainActor.run {
                self.weatherResponse = response
                self.weather = response.weather.first?.description ?? "no description"
                self.currentWeatherIcon = self.getIcon(weatherGroup: response.weather.first?.main ?? "Unknown")
            }

        } catch {
            await MainActor.run {
                self.weather = "unrecognisable weather"
                print("Weather fetch error: \(error.localizedDescription)")
            }
        }

        await MainActor.run {
            self.weatherLoading = false
        }
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



