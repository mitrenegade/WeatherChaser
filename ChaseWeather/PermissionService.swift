//
//  PermissionService.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/11/23.
//

import Foundation
import CoreLocation

protocol PermissionServiceDelegate: AnyObject {
    func permissionService(_ service: PermissionService, didUpdateLocation: CLLocation)
    func permissionService(_ service: PermissionService, didReceiveError: Error)
}

class PermissionService: NSObject {

    private let locationManager: CLLocationManager

    weak var delegate: PermissionServiceDelegate?

    override init() {
        locationManager = CLLocationManager()
        super.init()

        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestLocation()
    }
}

extension PermissionService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            delegate?.permissionService(self, didUpdateLocation: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.permissionService(self, didReceiveError: error)
    }
}
