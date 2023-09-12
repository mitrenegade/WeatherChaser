//
//  ChaseWeatherTests.swift
//  ChaseWeatherTests
//
//  Created by Bobby Ren on 9/8/23.
//

import XCTest
@testable import ChaseWeather

final class WeatherViewModelTests: XCTestCase {

    var weatherViewModel: WeatherViewModel!

    override func setUpWithError() throws {
        weatherViewModel = WeatherViewModel(apiService: MockAPIService())
    }

    override func tearDownWithError() throws {
        weatherViewModel = nil
    }

    func testCities() throws {
        Task {
            let weather = try await weatherViewModel.fetchWeather(for: "sanjose")
            XCTAssertEqual(weather.name, "San Jose")
        }
    }

}
