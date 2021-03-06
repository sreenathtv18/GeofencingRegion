//
//  GeofencingHelper.swift
//  Geofencing Demo
//
//  Created by Sreenath on 11/12/19.
//  Copyright © 2019 Sreenath. All rights reserved.
//

import Foundation
import CoreLocation




public class GeofencingRegion: NSObject, CLLocationManagerDelegate {
    
    // Declarations
    public static let shared = GeofencingRegion()

    public var allRegions: [CircularRegion] = []
    public lazy var locationManager: CLLocationManager? = { [weak self] in
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        return locationManager
    }()
    public var currentLocation: CLLocation? {
        didSet {
            startGeofencing()
        }
    }
    public weak var delegate: GeofencingProtocol?
    private var enteredRegion: CLRegion?
    
    // MARK: Life Cycle
    public override init() {
        
        super.init()
        //ask for location permission
        GeofencePermission.enableLocationServices(locationManager: locationManager)
        loadMonitoringRegions()
    }
    
    
    public func startUpdatingLocation() {

        locationManager?.startUpdatingLocation()
    }
    
    
    
    public func stopUpdatingLocation() {
        
        locationManager?.stopUpdatingLocation()
    }
    
    
    
    public func loadMonitoringRegions() {
        
        // Dummy data
        allRegions = CircularRegion.loadDummyData()
        
        /* Create a region centered on desired location,
         choose a radius for the region (in meters)
         choose a unique identifier for that region */
        for circularRegion in allRegions {
            let geofenceRegion = circularRegion.region
            geofenceRegion.notifyOnEntry = true
            geofenceRegion.notifyOnExit = true
            locationManager?.startMonitoring(for: geofenceRegion)
        }
    }
    
    
    
    public func evaluateClosestRegions(regions: [CircularRegion]) -> [CircularRegion] {
        
        var shortestRegions: [CircularRegion] = []
        //Calulate distance of each region's center to currentLocation
        shortestRegions = regions.map({ storableRegion in
            let distance = currentLocation?.distance(from: CLLocation(latitude: storableRegion.coordinate.latitude, longitude: storableRegion.coordinate.longitude))
            storableRegion.distance = distance ?? 0.0
            return storableRegion
        })


        //sort and get 20 closest
        let twentyNearbyRegions = regions
            .sorted{ $0.distance < $1.distance }
            .prefix(20)
        let twentyRegions: [CircularRegion] = Array(twentyNearbyRegions)
        
        return twentyRegions
    }
    
    func startGeofencing() {
        let twentyRegions = evaluateClosestRegions(regions: allRegions)
        stopMonitoringRegion()
        startMonitorRegion(twentyNearbyRegions: twentyRegions)

    }
    
    
    public func startMonitorRegion(twentyNearbyRegions: [CircularRegion]) {

        twentyNearbyRegions.forEach {
            locationManager?.startMonitoring(for: $0.region)
            locationManager?.requestState(for: $0.region)
        }
    }
    
    
    
    public func stopMonitoringRegion() {
        
        // Remove all regions you were tracking before
        guard let monitoredRegions = locationManager?.monitoredRegions else {
            return
        }
        
        for region in monitoredRegions {
            locationManager?.stopMonitoring(for: region)
        }
    }
}






// Location manager delegate methods
extension GeofencingRegion {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("didUpdateLocations", locations.first?.coordinate.latitude ?? 0.0 ,locations.first?.coordinate.longitude ?? 0.0)
        currentLocation = locations.first
        delegate?.getLatestCoordiante(location: currentLocation!)
    }
    
    
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("didFailWithError",error)
    }
    
    
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        enterGeofence(geofence: region, manager: manager)
    }



    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

        exitGeofence(geofence: region, manager: manager)
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {

            switch state {
            case .inside:
                enterGeofence(geofence: region, manager: manager)
                break
            case .outside:
                 exitGeofence(geofence: region, manager: manager)
                break
            case .unknown:
                print("Unknown state for geofence:",region)
                break
            default:
                break
            }
        }
    
     private func enterGeofence(geofence: CLRegion, manager: CLLocationManager) {
    
        print("didEnterRegion", geofence.identifier)
        if enteredRegion != geofence {
            enteredRegion = geofence
            delegate?.didEnterRegion()
        }
    }
    
    
    
     private func exitGeofence(geofence: CLRegion, manager: CLLocationManager) {
    
        print("didExitRegion", geofence.identifier)
        if enteredRegion == geofence {
            enteredRegion = nil
            currentLocation = manager.location
            delegate?.didExitRegion()
        }
    }
}
