//
//  ViewController.swift
//  GeofencingRegion
//
//  Created by sreenathtv18 on 12/31/2019.
//  Copyright (c) 2019 sreenathtv18. All rights reserved.
//

import UIKit
import GeofencingRegion
import CoreLocation
import MapKit

class ViewController: UIViewController, GeofencingProtocol, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        GeofencingRegion.shared.delegate = self
        GeofencingRegion.shared.startUpdatingLocation()
    }
    
    @IBAction func getNearByStore(_ sender: UIButton) {

        let allRegions = CircularRegion.loadDummyData()
        let closestRegion = GeofencingRegion.shared.evaluateClosestRegions(regions: allRegions)
        loadMapView(regions: closestRegion)
    }
    
    
    
    func loadMapView(regions: [CircularRegion]) {
        
        let currentLocation = GeofencingRegion.shared.currentLocation
        
        // 1
        guard let coordinate = currentLocation?.coordinate else { return }
                
            
        //3
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Current"
        annotation.subtitle = "My Location"
        mapView.addAnnotation(annotation)
        
        for (index, _region) in regions.enumerated() {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: _region.coordinate.latitude, longitude: _region.coordinate.longitude)
            annotation.title = "Region\(index)"
            print(annotation.title)
            mapView.addAnnotation(annotation)
            setRegion(coordinate: annotation.coordinate)

        }
    }
    
    
    
    func setRegion(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    func findRoute(destination: CLLocationCoordinate2D?) {
        // 1
        let currentLocation = GeofencingRegion.shared.currentLocation
        guard let sourceLocation = currentLocation?.coordinate else { return }

        // 2
        guard let destinationLocation = destination else { return }
        
        // 3.
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 4.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 7.
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    
    
    func removeOverlay(mapView: MKMapView?) {
        guard let _mapView = mapView else {return}
        _mapView.removeOverlays(_mapView.overlays)
    }
}

extension ViewController {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = view.annotation?.coordinate
        removeOverlay(mapView: mapView)
        findRoute(destination: location)

    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
}




extension ViewController {
                
    func didEnterRegion() {
        
        let alert = UIAlertController(title: "Enter Region", message: "You have entered a region. Enjoy your day", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    func didExitRegion() {
        
        let alert = UIAlertController(title: "Exit Region", message: "You have exit a region. Thanks for your visit", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: false, completion: nil)

    }
    
    func getLatestCoordiante(location: CLLocation) {
        
    }

}

