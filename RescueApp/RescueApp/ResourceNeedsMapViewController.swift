//
//  ResourceNeedsMapViewController.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit
import MapKit

class ResourceNeedsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    private var requests = [RequestModel]()
    
    struct C {
        static let animationIdentifier = "ResourceListViewControllerFlip"
        static let ResourceListViewController = "ResourceNeedsListViewController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialise()
        getResources()
    }

    func initialise() {
        //set delegate for mapview
        self.mapView.delegate = self
    }
    
    @IBAction func onTouchUpList(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: C.ResourceListViewController)
        UIView.beginAnimations(C.animationIdentifier, context: nil)
        UIView.setAnimationDuration(1.0)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationTransition(.flipFromRight, for: (navigationController?.view)!, cache: false)
        navigationController?.pushViewController(vc!, animated: true)
        UIView.commitAnimations()
    }

}

extension ResourceNeedsMapViewController {
    func getResources() {
        Overlay.shared.show()
        ApiClient.shared.getResourceNeeds { [weak self] (requests) in
            Overlay.shared.remove()
            self?.requests = requests
            DispatchQueue.main.async { [weak self] in
                self?.updateMap()
            }
        }
    }
    
    func updateMap() {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        mapView.addAnnotations(requests)
    }

    func showDirection(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)

        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }

            let route = directionResonse.routes[0]
            self.mapView.add(route.polyline, level: .aboveRoads)

            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
}

extension ResourceNeedsMapViewController: MKMapViewDelegate {
    //MARK:- MapKit delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}
