//
//  APIService.swift
//  WeatherChaser
//
//  Created by Bobby Ren on 9/8/23.
//

import UIKit
import Foundation
import CoreLocation

/// An interface for the OpenWeather API
protocol APIProvider {
    /// Fetches the weather based on location
    /// - Parameters:
    ///     - city: a nonoptional string for the name of the city
    ///     - state: an optional string for the state
    ///     - country: an optional string for the country
    func weather(for city: String, state: String?, country: String?) async throws -> Weather

    /// Fetches the name of the current location based on GPS coordinates
    /// - Parameters:
    ///     - location: a coordinate containing latitute and longitude
    func reverseGeocode(for location: CLLocation) async throws -> String
}

class APIService: APIProvider {

    private let APIKey = "d9db8536cc43335fcfc3f767bbc8098e"
    private let baseURL = "https://api.openweathermap.org"

    // MARK: - Types

    enum APIError: Error {
        case invalidURL
        case geocodeError
        case decodeError
    }

    enum Endpoint {
        case weather
        case geocoding

        var path: String {
            switch self {
            case .weather:
                return "/data/2.5/weather"
            case .geocoding:
                return "/geo/1.0/reverse"
            }
        }
    }

    enum ParamKey {
        static let appID = "appid"
        static let query = "q"
        static let lat = "lat"
        static let lon = "lon"
        static let limit = "limit"
    }

    // MARK: - Properties

    private let decoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    // MARK: - Functions

    private func query(for endpoint: Endpoint, params: [String: String]) throws -> URLRequest {
        var allParams = params
        allParams[ParamKey.appID] = APIKey

        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = endpoint.path
        urlComponents?.queryItems = allParams.map({ key, val -> URLQueryItem in
            URLQueryItem(name: key, value: val)
        })
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        return URLRequest(url: url)
    }

    private func fetch(_ endpoint: Endpoint, params: [String: String]) async throws -> Data {
        let request = try query(for: endpoint, params: params)
        
        let (data, _) = try await URLSession.shared.data(for: request)

        return data
    }

    // MARK: - Public

    func weather(for city: String, state: String? = nil, country: String? = nil) async throws -> Weather {
        let query: String
        if let state, let country {
            query = [city, state, country].joined(separator: ",")
        } else if let country {
            query = [city, country].joined(separator: ",")
        } else {
            query = city
        }
        let params: [String: String] = [ParamKey.query: query]
        let data = try await fetch(.weather, params: params)
        do {
            let weather = try decoder.decode(Weather.self, from: data)
            return weather
        } catch _ as Swift.DecodingError {
            // this error is used to track issues where the API may no longer be compatible
            // but the app should handle it cleanly
            throw APIError.decodeError
        }
    }

    func reverseGeocode(for location: CLLocation) async throws -> String {
        let params: [String: String] = [ParamKey.lat: "\(location.coordinate.latitude)",
                                        ParamKey.lon: "\(location.coordinate.longitude)",
                                        ParamKey.limit: "1"]

        let data = try await fetch(.geocoding, params: params)
        let cities = try decoder.decode([ReverseGeocodeLocation].self, from: data)
        guard let name = cities.first?.name else {
            throw APIError.geocodeError
        }
        return name
    }
}
