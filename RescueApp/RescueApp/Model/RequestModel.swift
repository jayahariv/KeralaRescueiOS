//
//  RequestModel.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

enum RequestStatus{
    case new;
    case inProgress;
    case closed;
}

final class RequestModel: NSObject, Codable {
    var dateadded: String?
    var detailcloth: String?
    var detailfood: String?
    var detailkit_util: String?
    var detailmed: String?
    var detailrescue: String?
    var detailtoilet: String?
    var detailwater: String?
    var district: District?
    var id: Int?
    var is_request_for_others: Bool = false
    var lat: Double?
    var lon: Double?
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
    var status: RequestStatus?
    var supply_details: String?
    
    enum CodingKeys: String, CodingKey {
        case dateadded
        case detailcloth
        case detailfood
        case detailkit_util
        case detailmed
        case detailrescue
        case detailtoilet
        case detailwater
        //        case district // TODO:
        case id
        case is_request_for_others
//        case lat
//        case lon
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
//        case status: RequestStatus?
        case supply_details
    }
}
