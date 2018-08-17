//
//  ProvideResourcesViewController.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit
import MapKit

class ProvideResourcesViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getResources()
    }

}


extension ProvideResourcesViewController {
    func getResources() {
        ApiClient.shared.getResourceNeeds { (requests) in
            print(requests)
        }
    }
}
