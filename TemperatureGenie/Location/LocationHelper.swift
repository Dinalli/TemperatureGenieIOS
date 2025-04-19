//
//  LocationHelper.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 19/04/2025.
//

import Foundation
import CoreLocation

public class LocationHelper: NSObject, ObservableObject {
    private var locationManager = CLLocationManager()

    @Published var locationActive: Bool = false {
        didSet{
            if locationActive == false {
                locationManager.stopUpdatingLocation()
            } else {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    @Published var currentLocation: CLLocation?

    func checkLocationState() {
        locationManager.delegate = self
        DispatchQueue.main.async {
            if self.locationManager.authorizationStatus == .denied {
                // Send Event
            } else if self.locationManager.authorizationStatus == .notDetermined {
                self.locationManager.requestAlwaysAuthorization()
            } else if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedAlways {
                self.locationActive = true
                self.locationManager.startUpdatingLocation()
            }
        }
    }
}

extension LocationHelper: CLLocationManagerDelegate {
    /// Location Manager Delegate method to capture latest location and show it on the map as user Location
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let capturedLocation = manager.location {
            currentLocation = capturedLocation
        }
    }

    /// Location Manager Delegate method to action change in location authorization
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .restricted, .denied:
                locationActive = false
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
                locationActive = false
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                locationActive = true
            @unknown default:
                break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR UPDATING LOCATION \(error.localizedDescription)")
    }
}

