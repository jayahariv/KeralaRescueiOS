//
/*
EmergencyContactUtil.swift
Created on: 16/9/18

Abstract:
 this will be common utility methods for emergencyContacts

*/

import Foundation
import CouchbaseLiteSwift

final class EmergencyContactUtil: NSObject {
    static func fetchContacts() -> [EmergencyContact] {
        guard let database = try? Database(name: "RescueApp") else {
            return []
        }
        
        let document = database.document(withID: APIConstants.CBL_KEYS.EMERGENCY_CONTACTS_ROOT_KEY)
        var tempContacts = [EmergencyContact]()
        for key in document?.keys ?? [] {
            if
                let emergencyContact = document?.string(forKey: key),
                let contact = EmergencyContact.fromString(emergencyContact)
            {
                tempContacts.append(contact)
            }
        }
        return tempContacts
    }
}
