//
//  WeatherChaserTests.swift
//  WeatherChaserTests
//
//  Created by Bobby Ren on 9/8/23.
//

import XCTest
@testable import WeatherChaser

final class WeatherViewModelTests: XCTestCase {

    var weatherViewModel: WeatherViewModel!

    override func setUpWithError() throws {
        weatherViewModel = WeatherViewModel(apiService: MockAPIService())
    }

    override func tearDownWithError() throws {
        weatherViewModel = nil
    }

    func testCities() async throws {
        let weather = try await weatherViewModel.fetchWeather(for: "sanjose")
        XCTAssertEqual(weather.name, "San Jose")
        XCTAssertEqual(weather.sunriseString, "06:46:18")
    }

}
