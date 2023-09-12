//
//  PermissionService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import CoreLocation

protocol PermissionServiceDelegate: AnyObject {
    func permissionService(_ service: PermissionService, didUpdateLocation location: CLLocation)
    func permissionService(_ service: PermissionService, didReceiveError error: Error)
}

class PermissionService: NSObject {

    private let locationManager: CLLocationManager

    weak var delegate: PermissionServiceDelegate?

    private var currentLocation: CLLocation?

    override init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
    }

    func requestLocationPermissions() {
        locationManager.requestAlwaysAuthorization()
    }

    func queryCurrentLocation() -> CLLocation? {
        if let currentLocation {
            return currentLocation
        } else {
            requestLocationPermissions()
            return nil
        }
    }
}

extension PermissionService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = location
            delegate?.permissionService(self, didUpdateLocation: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.permissionService(self, didReceiveError: error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            print("no authorization: \(manager.authorizationStatus)")
        }
    }
}
