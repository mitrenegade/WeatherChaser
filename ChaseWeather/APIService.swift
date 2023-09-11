//
//  APIService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/8/23.
//

import UIKit
import Foundation

class APIService {

    private let APIKey = "d9db8536cc43335fcfc3f767bbc8098e"
    private let baseURL = "https://api.openweathermap.org"

    // MARK: - Types

    enum APIError: Error {
        case invalidURL
        case invalidImageData
        case requestError
    }

    enum Endpoint {
        case weather
        case geocoding
        case icon(String)

        var path: String {
            switch self {
            case .weather:
                return "/data/2.5/weather/"
            case .geocoding:
                return "/geo/1.0/direct/"
            case .icon(let name):
                return "/img/wn/\(name)@2x.png"
            }
        }
    }

    enum ParamKey {
        static let appID = "appid"
        static let query = "q"
    }

    // MARK: - Properties

    private let decoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    // MARK: - Functions

    private func query(for endpoint: Endpoint, params: [String: String]?) throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = endpoint.path
        urlComponents?.queryItems = params?.map({ key, val -> URLQueryItem in
            URLQueryItem(name: key, value: val)
        })
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        return URLRequest(url: url)
    }

    private func fetchWeather(for params: [String: String]?) async throws -> Weather {
        let request = try query(for: .weather, params: params)
        
        let (data, _) = try await URLSession.shared.data(for: request)

        if let string = String(data: data, encoding: .utf8) {
            print(string)
        }
        
        return try decoder.decode(Weather.self, from: data)
    }

    // MARK: - Public

    func weather(for city: String, state: String? = nil, country: String? = nil) async throws -> Weather {
        var params: [String: String] = [ParamKey.appID: APIKey]
        let query: String
        if let state, let country {
            query = [city, state, country].joined(separator: ",")
        } else if let country {
            query = [city, country].joined(separator: ",")
        } else {
            query = city
        }
        params[ParamKey.query] = query
        return try await fetchWeather(for: params)
    }

    /// Parameters:
    /// - name: the icon code as a string. ie, `10d` for an icon named `10d@2x.png`
    func icon(for name: String) async throws -> UIImage {
        let request = try query(for: .icon(name), params: nil)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let image = UIImage(data: data) else {
            throw APIError.invalidImageData
        }
        return image
    }
}
