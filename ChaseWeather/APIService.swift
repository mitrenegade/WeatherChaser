//
//  APIService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/8/23.
//

import Foundation

class APIService {

    private let APIKey = "d9db8536cc43335fcfc3f767bbc8098e"
    private let baseURL = "https://api.openweathermap.org"

    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case requestError
    }

    enum Endpoint {
        case weather
        case geocoding

        var path: String {
            switch self {
            case .weather:
                return "data/2.5/weather"
            case .geocoding:
                return "geo/1.0/direct"
            }
        }
    }

    enum ParamKey {
        static let appID = "appid"
        static let query = "q"
    }

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

    private func performRequest(_ endpoint: Endpoint, params: [String: String]?) async throws -> [String: Any] {
        let request = try query(for: endpoint, params: params)

        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            return json
        }

        throw APIError.invalidResponse
    }

    // MARK: - Public

    func weather(for city: String, state: String? = nil, country: String? = nil) async throws -> [String: Any] {
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
        return try await performRequest(.weather, params: params)
    }
}
