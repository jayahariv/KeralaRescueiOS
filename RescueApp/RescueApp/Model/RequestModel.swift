//
//  RequestModel.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation
import MapKit

enum RequestStatus{
    case new;
    case inProgress;
    case closed;
}

final class RequestModel: NSObject, Codable, MKAnnotation {
    var dateadded: String?
    var detailcloth: String?
    var detailfood: String?
    var detailkit_util: String?
    var detailmed: String?
    var detailrescue: String?
    var detailtoilet: String?
    var detailwater: String?
    var district: String?
    var id: Int?
    var is_request_for_others: Bool = true
    var latlng: String?
    var latlng_accuracy: String?
    var location: String?
    var needcloth: Bool = false
    var needfood: Bool = false
    var needkit_util: Bool = false
    var needmed: Bool = false
    var needothers: String?
    var needrescue: Bool = false
    var needtoilet: Bool = false
    var needwater: Bool = false
    var requestee: String?
    var requestee_phone: String?
    var status: String?
    var supply_details: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    var title: String? {
        return requestee
    }
    
    var subtitle: String? {
        return location
    }
    
    var lat: Double {
        let latlongArray = latlng?.split(separator: ",")
        guard let latlonString = latlongArray?.first else {
            return 0.0
        }
        
        guard let validDouble = Double(String(latlonString)) else {
            return 0.0
        }
        
        return validDouble
    }
    var lon: Double {
        let latlongArray = latlng?.split(separator: ",")
        guard let latlonString = latlongArray?.last else {
            return 0.0
        }
        
        guard let validDouble = Double(String(latlonString)) else {
            return 0.0
        }
        return validDouble
    }
    
    var requestStatus: RequestStatus? {
        return .new
    }
    
    var districtEnum: District {
        return District.getFromString(district)
    }
    
    enum CodingKeys: String, CodingKey {
        case dateadded
        case detailcloth
        case detailfood
        case detailkit_util
        case detailmed
        case detailrescue
        case detailtoilet
        case detailwater
        case district
        case id
        case is_request_for_others
        case latlng
        case latlng_accuracy
        case location
        case needcloth
        case needfood
        case needkit_util
        case needmed
        case needothers
        case needrescue
        case needtoilet
        case needwater
        case requestee
        case requestee_phone
        case status
        case supply_details
    }
}
