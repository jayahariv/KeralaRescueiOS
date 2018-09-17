//
/*
APIConstants.swift
Created on: 8/17/18

Abstract:
 shared constants for the 

*/

import Foundation
import FirebaseDatabase

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
    struct CBL_KEYS {
        static let EMERGENCY_CONTACTS_ROOT_KEY = "couchbase_emergency_contacts_root_key"
        static let FIRSTNAME = "firstName"
        static let FAMILY_NAME = "familyName"
        static let PHONE_NUMBERS = "phonenumbers"
        static let EMAIL_ADDRESSES = "emailAddresses"
    }
    
    // PLIST CONSTANTS
    struct PLIST_KEYS {
        static let NAME = "OfflineData"
        static let INDIVIDUAL_REQUESTS = "individual_requests"
        static let RELIEF_CAMP_KEY = "relief_camps"
    }
    
    static let API_REQUEST_TIMEOUT = 10.0 
}


// MARK: Firebase saved URLs

final class FirebaseAPIConfigure: NSObject {
    private static let instance = FirebaseAPIConfigure(Database.database().reference())
    static var shared: FirebaseAPIConfigure {
        return instance
    }
    private var ref: DatabaseReference?
    private var urlInformation: [String: AnyObject]?
    
    init(_ dbRef: DatabaseReference?) {
        super.init()
        ref = dbRef
        ref?.child("API_END_POINTS").observe(DataEventType.value, with: { [weak self] (snapshot) in
            self?.urlInformation = snapshot.value as? [String : AnyObject] ?? [:]
        })
    }
    
    /**
     this should be called in AppDelegate to get the Firebase data before using it anywhere in the code
     
     */
    func configure() {
        print("this is a hack to make sure the data is loaded before using")
    }
    
    /**
     individual requests URL
     
     - returns: if a valid URL in firebase. that will return the URL object, else nil
     */
    func getIndividualRequestsURL() -> URL? {
        guard let urlString = urlInformation?["individual_requests"] as? String else {
            return nil
        }
        return URL(string: urlString)
    }
    
    /**
     relief camps reqeusts URL
     
     - returns: Valid URL is present in the Firebase, then URL, else nil
     */
    func getReliefCampsRequestsURL() -> URL? {
        guard let urlString = urlInformation?["relief_camps"] as? String else {
            return nil
        }
        return URL(string: urlString)
    }
}
