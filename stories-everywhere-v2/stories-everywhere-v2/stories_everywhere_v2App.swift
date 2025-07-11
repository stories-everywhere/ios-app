//
//  stories_everywhere_v2App.swift
//  stories-everywhere-v2
//
//  Created by Rachele Guzzon on 16/05/2025.
//

import SwiftUI
import CoreLocation

@main
struct stories_everywhere_v2App: App {
    @StateObject var promptInputs : PromptInputs = PromptInputs()
    @StateObject var deviceSpeed : DeviceSpeed = DeviceSpeed()

    
    var body: some Scene {
        WindowGroup {
            CameraView(promptInputs: promptInputs, deviceSpeed: deviceSpeed)
        }
    }
}

@MainActor
class PromptInputs: ObservableObject {
    @Published var weather: String = "unknown Weather"
    @Published var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var date: String = "unknown Date"
    @Published var weatherIcon: String = "questionmark.circle.dashed"
    @Published var weatherLoading: Bool = false
    @Published var locationLoading: Bool = false
    
    @ObservedObject var weatherManager = WeatherManager()

    init() {
        print("begin init")
        self.date = Date().formatted()
        
        Task {
            await self.weatherManager.getLocationWeather()
            self.initialisedWeather()
        }
    }

    func initialisedWeather() {
        self.location = self.weatherManager.currentLocation ?? CLLocationCoordinate2D()
        self.weather = self.weatherManager.weather
        self.weatherIcon = self.weatherManager.currentWeatherIcon
        self.weatherLoading = self.weatherManager.weatherLoading
        self.locationLoading = self.weatherManager.locationLoading
    }
}

@MainActor
class DeviceSpeed: ObservableObject {
    @Published var speed : CLLocationSpeed = 0
    init() {
        self.speed = CLLocationSpeed()
    }

}


