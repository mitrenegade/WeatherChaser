//
//  MockAPIService.swift
//  ChaseWeatherTests
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import CoreLocation
@testable import ChaseWeather

class MockAPIService: APIProvider {

    enum MockError: Error {
        case fileNotFound
    }

    private func loadData(for stub: String) throws -> Data {
        guard
            let url = Bundle(for: type(of: self)).url(
                forResource: stub,
                withExtension: "json"
            )
        else {
            throw MockError.fileNotFound
        }

        return try Data(contentsOf: url)
    }


    func weather(for city: String, state: String?, country: String?) async throws -> Weather {
        let data = try loadData(for: city)
        let weather = try JSONDecoder().decode(Weather.self, from: data)
        return weather
    }

    func reverseGeocode(for location: CLLocation) async throws -> String {
        return "San Jose"
    }


}
