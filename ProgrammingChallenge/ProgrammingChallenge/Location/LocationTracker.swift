//
//  LocationTracker.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/18/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationError {
    // system denied auth (e.g. airplane mode)
    case systemDenied
    
    // user denied auth (e.g. disabling app location)
    case userDenied
    
    // CLLocationManager failed
    case error(String)
    
    // location succeeded, but no locations array was empty
    case emptyLocation
}

enum LocationResult {
    case success(CLLocation)
    case failure(LocationError)
}

protocol LocationTrackerDelegate: class {
    func didFinish(_ tracker: LocationTracker, result: LocationResult)
}

class LocationTracker: NSObject {
    
    let locationManager = CLLocationManager()
    weak var delegate: LocationTrackerDelegate?
    
    // MARK: Public API
    
    func getLocation() {
        // set the delegate only when needed, after init
        // prevents didChangeAuthorization spam
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        configure(CLLocationManager.authorizationStatus())
    }
        
    fileprivate func configure(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            print("LocationTracker: requesting auth...")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            print("LocationTracker: tracking location...")
            locationManager.requestLocation()
        case .denied:
            print("LocationTracker: user denied")
            delegate?.didFinish(self, result: .failure(.userDenied))
        case .restricted:
            print("LocationTracker: system denied")
            delegate?.didFinish(self, result: .failure(.systemDenied))
        }
    }
    
}

extension LocationTracker: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("LocationTracker: found location: \(location)")
        manager.stopUpdatingLocation()
        delegate?.didFinish(self, result: .success(location))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationTracker: failed: " + error.localizedDescription)
        manager.stopUpdatingLocation()
        delegate?.didFinish(self, result: .failure(.error(error.localizedDescription)))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        configure(status)
    }
    
}
