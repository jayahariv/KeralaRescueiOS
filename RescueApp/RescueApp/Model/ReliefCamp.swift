//
/*
ReliefCamp.swift
Created on: 22/8/18

Abstract:
 this will be model which represent each relief camp

*/

import Foundation

enum ReliefCampStatusType {
    case closed
    case active
    case duplicate
    case unknown
}

final class ReliefCamp: NSObject, Codable {
    
    // MARK: Default keys from JSON
    var id: String?
    var name: String?
    var location: String?
    var district: String?
    var taluk: String?
    var village: String?
    var contacts: String?
    var facilities_available: String?
    var data_entry_user_id: String?
    var map_link: String?
    var latlng: String?
    var total_people: Int = 0
    var total_males: Int = 0
    var total_females: Int = 0
    var total_infants: Int = 0
    var food_req: String?
    var clothing_req: String?
    var sanitary_req: String?
    var medical_req: String?
    var other_req: String?
    var status: String?
    
    /// MARK: Computed properties
    var reliefCampStatus: ReliefCampStatusType {
        if status == "active" {
            return .active
        } else if status == "closed" {
            return .closed
        } else if status == "duplicate" {
            return .duplicate
        } else {
            return .unknown
        }
    }
    
    
    // MARK: FOR JSONCoder
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case district
        case taluk
        case village
        case contacts
        case facilities_available
        case data_entry_user_id
        case map_link
        case latlng
        case total_people
        case total_males
        case total_females
        case total_infants
        case food_req
        case clothing_req
        case sanitary_req
        case medical_req
        case other_req
        case status
    }
}
