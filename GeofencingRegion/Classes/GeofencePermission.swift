//
//  GeofencePermission.swift
//  Geofencing Demo
//
//  Created by Sreenath on 19/12/19.
//  Copyright © 2019 Sreenath. All rights reserved.
//

import Foundation
import CoreLocation

public class GeofencePermission {
    

    // to check status of locations
    public static func enableLocationServices(locationManager: CLLocationManager?) {
        
        guard let _locationManager: CLLocationManager = locationManager else { return }
        
        switch CLLocationManager.authorizationStatus() {
        
        case .notDetermined:
            // Request when-in-use authorization initially
            _locationManager.requestAlwaysAuthorization()
            break
            
        case .restricted, .denied:
            print("status restricted, .denied \(CLLocationManager.authorizationStatus())")
            // Disable location features
    
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            print("status authorizedWhenInUse \(CLLocationManager.authorizationStatus())")
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            print("status authorizedAlways \(CLLocationManager.authorizationStatus())")
            break
            
        default:
            _locationManager.requestAlwaysAuthorization()
        }
    }
}

