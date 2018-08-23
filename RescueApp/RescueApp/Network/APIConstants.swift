//
/*
APIConstants.swift
Created on: 8/17/18

Abstract:
 shared constants for the 

*/

import Foundation

struct APIConstants {
    
    // API URLs and ist keys
    struct URL {
        static let INDIVIDUAL_REQUESTS = "https://keralarescue.in/data/?"
        static let RELIEF_CAMPS = "https://keralarescue.in/relief_camps/data?"
    }
    static let PAGINATION_OFFSET_KEY = "offset"
    
    // couchbase database - keys
    static let COUCHBASE_OFFLINE_SAVE_ROOT_KEY = "couchbase_offline_save_root_key"
    static let REQUESTS_OFFLINE_SAVE_KEY = "individual_requests_offline_save_key"
    static let RELIEF_CAMPS_OFFLINE_SAVE_KEY = "relief_camps_offline_save_key"
    
    // PLIST CONSTANTS
    struct PLIST_KEYS {
        static let NAME = "OfflineData"
        static let INDIVIDUAL_REQUESTS = "individual_requests"
        static let RELIEF_CAMP_KEY = "relief_camps"
    }
    
    static let API_REQUEST_TIMEOUT = 10.0 
}
