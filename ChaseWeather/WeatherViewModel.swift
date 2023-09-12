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
    func didReceiveLocationError(_ error: Error)
    func didDenyLocationPermission()
}

class WeatherViewModel {

    // MARK: - Properties

    private let apiService: APIProvider
    private let imageService: ImageService
    private let permissionService: PermissionService

    weak var delegate: WeatherViewModelDelegate?

    // MARK: -

    init(apiService: APIProvider = APIService(),
         imageService: ImageService = ImageService(),
         permissionService: PermissionService = PermissionService()) {

        self.apiService = apiService
        self.imageService = imageService
        self.permissionService = permissionService
        permissionService.delegate = self
    }

    // MARK: - Public functions

    /// Requests the weather for a given location.
    /// - Parameters:
    ///     - city: the name of the city
    func fetchWeather(for city: String) async throws -> Weather {
        // TODO: use state and country when UI is available
        try await apiService.weather(for: city, state: nil, country: nil)
    }

    /// Requests a weather icon.
    /// - Parameters:
    ///     - weatherDetail: an object that contains the icon's name
    func fetchWeatherIcon(for weatherDetail: WeatherDetail) async throws -> UIImage {
        try await imageService.icon(for: weatherDetail)
    }

    /// Fetches the current GPS location or starts the process to request the permission.
    func fetchCurrentLocation() {
        permissionService.queryCurrentLocation()
    }
}

// MARK: - GeoCoding {
extension WeatherViewModel {
    func reverseGeocode(location: CLLocation) {
        Task {
            do {
                let city = try await apiService.reverseGeocode(for: location)
                delegate?.didFinishReverseGeocode(city)
                permissionService.isFetchingLocation = false
            } catch let error {
                delegate?.didReceiveLocationError(error)
            }
        }
    }
}

// MARK: - PermissionServiceDelegate
extension WeatherViewModel: PermissionServiceDelegate {
    func permissionServiceDidDenyLocation(_ service: PermissionService) {
        delegate?.didDenyLocationPermission()
    }

    func permissionService(_ service: PermissionService, didUpdateLocation location: CLLocation) {
        reverseGeocode(location: location)
    }

    func permissionService(_ service: PermissionService, didReceiveError error: Error) {
        print("Error \(error)")
        delegate?.didReceiveLocationError(error)
    }
}
