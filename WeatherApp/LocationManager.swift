//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Lincoln Takudzwa Nyarambi on 11/17/24.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Location request will be made after authorization is granted
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            // Notify the user that location access is denied
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .locationAccessDenied, object: nil)
            }
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted.")
        case .denied, .restricted:
            print("Location access denied or restricted.")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .locationAccessDenied, object: nil)
            }
        case .notDetermined:
            print("Location access not determined.")
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = location.coordinate
                print("Updated location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}

extension Notification.Name {
    static let locationAccessDenied = Notification.Name("locationAccessDenied")
}
