//
//  PermissionService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import CoreLocation

/// An delegate protocol for location permissions
protocol PermissionServiceDelegate: AnyObject {
    /// Returns the most recent location received
    func permissionService(_ service: PermissionService, didUpdateLocation location: CLLocation)

    /// Returns an error received from the location service
    func permissionService(_ service: PermissionService, didReceiveError error: Error)

    /// Notifies that location permissions have been denied
    func permissionServiceDidDenyLocation(_ service: PermissionService)
}

class PermissionService: NSObject {

    // MARK: - Properties

    private let locationManager: CLLocationManager

    private var currentLocation: CLLocation?

    weak var delegate: PermissionServiceDelegate?

    var isFetchingLocation = false

    // MARK: -

    override init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
    }

    // MARK: - Public functions

    func requestLocationPermissions() {
        locationManager.requestAlwaysAuthorization()
    }

    func queryCurrentLocation() {
        isFetchingLocation = true
        if let currentLocation {
            delegate?.permissionService(self, didUpdateLocation: currentLocation)
        } else if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestLocation()
        } else if locationManager.authorizationStatus == .denied {
            delegate?.permissionServiceDidDenyLocation(self)
        } else {
            requestLocationPermissions()
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
            if isFetchingLocation {
                manager.requestLocation()
            }
        case .denied:
            if isFetchingLocation {
                delegate?.permissionServiceDidDenyLocation(self)
            }
        default:
            print("no authorization: \(manager.authorizationStatus)")
        }
    }
}
