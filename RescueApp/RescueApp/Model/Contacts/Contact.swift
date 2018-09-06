//
/*
Contact.swift
Created on: 24/8/18

Abstract:
 this will be the contact model

*/

import Foundation

class Contact: NSObject {
    var name: String?
    var numbers: [String]?
    
    init(_ contacteeName: String, phone: AnyObject) {
        super.init()
        name = contacteeName
        if let contacts = phone as? [String: String] {
            numbers = Array(contacts.values)
        }
    }
}
