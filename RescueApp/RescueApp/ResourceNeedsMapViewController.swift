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
    
    private var requests:  [String: RequestModel] {
        return ResultOptimizer.shared.filtered
    }
    private let locationManager = CLLocationManager()
    
    struct C {
        static let animationIdentifier = "ResourceListViewControllerFlip"
        static let ResourceListViewController = "ResourceNeedsListViewController"
        static let mapAnnotationIdentifier = "MapAnnotationIdentifier"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialise()
        getResources()
        getCurrentLocation()
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
        ApiClient.shared.getResourceNeeds { [weak self] in
            Overlay.shared.remove()
            DispatchQueue.main.async { [weak self] in
                self?.updateMap()
            }
        }
    }
    
    func updateMap() {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        let annotations = Array(requests.values).filter{!$0.is_request_for_others}
        mapView.addAnnotations(annotations)
    }
    
    /**
     gets current location.
     */
    func getCurrentLocation() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    
    /**
     sets the region of the map with given latitide, longitude and delta(for both latitude and longitude)
     - parameters:
     - latitude: self descriptive
     - longitude: self descriptive
     - delta: this delta will be used for both latitude and longitude delta values
     */
    func setRegion(_ latitude: Double, longitude: Double, delta: Double) {
        let span = MKCoordinateSpan(latitudeDelta: delta,
                                    longitudeDelta: delta)
        let center = CLLocationCoordinate2D(latitude: latitude,
                                            longitude: longitude)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
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
                    let simpleAlert = Alert.errorAlert(title: "Error", message: error.localizedDescription)
                    self.present(simpleAlert, animated: true)
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

// MARK: AddToiletViewController -> CLLocationManagerDelegate
extension ResourceNeedsMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = manager.location {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            mapView.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: location.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            mapView.setRegion(region, animated: true)
        }
        
    }
}

// MARK: MapViewController -> MKMapViewDelegate
extension ResourceNeedsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? RequestModel else { return nil }
        var view: RAAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: C.mapAnnotationIdentifier)
            as? RAAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = RAAnnotationView(annotation: annotation, reuseIdentifier: C.mapAnnotationIdentifier)
        }
        return view
    }
    
    //MARK:- MapKit delegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
}


//MARK: MapViewController -> CIAddressTypeaheadProtocol

extension ResourceNeedsMapViewController: RAAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(placemark.coordinate.latitude,
                                                           placemark.coordinate.longitude)
        annotation.title = placemark.title
        annotation.subtitle = placemark.subLocality
        
        mapView.addAnnotation(annotation)
        
        setRegion(placemark.coordinate.latitude,
                  longitude: placemark.coordinate.longitude,
                  delta: 0.02)
    }
}
