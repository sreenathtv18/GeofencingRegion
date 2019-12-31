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

class ViewController: UIViewController, GeofencingProtocol {

    @IBOutlet weak var locationTextView: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GeofencingRegion.shared.delegate = self
        GeofencingRegion.shared.startUpdatingLocation()
    }

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
        locationTextView.text = locationTextView.text + "\(location.coordinate)\n"
    }

}

