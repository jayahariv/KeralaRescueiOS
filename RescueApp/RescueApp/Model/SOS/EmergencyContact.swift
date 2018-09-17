//
/*
EmergencyContact.swift
Created on: 16/9/18

Abstract:
 this will be the emergency contacts of the user

*/

import Foundation
import Contacts
import CouchbaseLiteSwift

final class EmergencyContact: NSObject, Codable {
    private var id: String?
    private var firstName: String?
    private var familyName: String?
    private var phoneNumbers = [String]()
    private var emailAddress = [String]()
    
    init(_ contact: CNContact) {
        super.init()
        id = contact.identifier
        firstName = contact.givenName
        familyName = contact.familyName
        var tempNumbers = [String]()
        for number in contact.phoneNumbers {
            tempNumbers.append(number.value.stringValue)
        }
        phoneNumbers  = tempNumbers
        var tempEmailAddress = [String]()
        for email in contact.emailAddresses {
            tempEmailAddress.append(String(email.value))
        }
        emailAddress = tempEmailAddress
    }
    
    init(_ id: String?, firstName: String?, familyName: String?, phonenumbers:[String], emailAddresses: [String]) {
        super.init()
        self.id = id
        self.firstName = firstName
        self.familyName = familyName
        self.phoneNumbers = phonenumbers
        self.emailAddress = emailAddresses
    }
    
    var displayName: String {
        return (firstName ?? "--") + (familyName ?? "--")
    }
    
    var contactNumbers: [String] {
        return phoneNumbers
    }
    
    func save() {
        guard let identifier = id else {
            return
        }
        
        guard let str = self.toString() else {
            return
        }
        
        do {
            let database = try Database(name: "RescueApp")
            let savedDoc = database.document(withID: APIConstants.CBL_KEYS.EMERGENCY_CONTACTS_ROOT_KEY)
            let doc = MutableDocument(id: APIConstants.CBL_KEYS.EMERGENCY_CONTACTS_ROOT_KEY)
            for key in savedDoc?.keys ?? [] {
                if let value = savedDoc?.string(forKey: key) {
                    doc.setString(value, forKey: key)
                }
            }
            doc.setString(str, forKey: identifier)
            try database.saveDocument(doc)
            print("saved: \(identifier)")
        } catch {
            print("test")
        }
    }
    
    func toString() -> String? {
        do {
            let numberData = try JSONSerialization.data(withJSONObject: phoneNumbers, options: [])
            let numberString = String(data: numberData, encoding: .utf8)
            let emailData = try JSONSerialization.data(withJSONObject: emailAddress, options: [])
            let emailString = String(data: emailData, encoding: .utf8)
            let dictionary = ["id": id,
                              "firstName": firstName,
                              "familyName": familyName,
                              "phoneNumbers": numberString,
                              "emailaddresses": emailString]
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    static func fromString(_ string: String) -> EmergencyContact? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            let id = json?["id"] as? String
            let tempFirstName = json?["firstName"] as? String
            let tempFamilyName = json?["familyName"] as? String
            let phoneNumbers = json?["phoneNumbers"] as? String
            guard let phoneNumberData = phoneNumbers?.data(using: .utf8) else {
                return nil
            }
            let tempPhoneNumbers =
                try JSONSerialization.jsonObject(with: phoneNumberData, options: []) as? [String]
            let emailAddresses = json?["emailaddresses"] as? String
            guard let emailAddressesData = emailAddresses?.data(using: .utf8) else {
                return nil
            }
            let tempEmailAddresses =
                try JSONSerialization.jsonObject(with: emailAddressesData, options: []) as? [String]
            return EmergencyContact.init(id,
                                         firstName: tempFirstName,
                                         familyName: tempFamilyName,
                                         phonenumbers: tempPhoneNumbers ?? [],
                                         emailAddresses: tempEmailAddresses ?? [])
            
        } catch {
            print(error)
            return nil
        }
    }
}
