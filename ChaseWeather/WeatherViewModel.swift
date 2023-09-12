//
//  WeatherViewModel.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import CoreLocation
import UIKit

protocol WeatherViewModelDelegate: AnyObject {
    func didFinishReverseGeocode(_ city: String)
}

class WeatherViewModel {
    private let apiService: APIProvider
    private let imageService: ImageService
    private let permissionService: PermissionService

    weak var delegate: WeatherViewModelDelegate?

    init(apiService: APIProvider = APIService(),
         imageService: ImageService = ImageService(),
         permissionService: PermissionService = PermissionService()) {

        self.apiService = apiService
        self.imageService = imageService
        self.permissionService = permissionService
        permissionService.delegate = self
    }

    func fetchWeather(for city: String) async throws -> Weather {
        try await apiService.weather(for: city, state: nil, country: nil)
    }

    func fetchImage(for weatherDetail: WeatherDetail) async throws -> UIImage {
        try await imageService.icon(for: weatherDetail)
    }

    func fetchCurrentLocation() {
        permissionService.queryCurrentLocation()
    }
}

// MARK: - GeoCoding {
extension WeatherViewModel {
    func reverseGeocode(location: CLLocation) {
        print("Location \(location)")
        Task {
            do {
                let city = try await apiService.reverseGeocode(for: location)
                print("Reverse geocode: \(city)")
                delegate?.didFinishReverseGeocode(city)
            } catch {
                print("Geocode failed")
            }
        }
    }
}

// MARK: - PermissionServiceDelegate
extension WeatherViewModel: PermissionServiceDelegate {
    func permissionService(_ service: PermissionService, didUpdateLocation location: CLLocation) {
        reverseGeocode(location: location)
    }

    func permissionService(_ service: PermissionService, didReceiveError error: Error) {
        print("Error \(error)")
    }
}
