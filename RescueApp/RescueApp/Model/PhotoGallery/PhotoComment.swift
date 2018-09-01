//
/*
PhotoComment.swift
Created on: 31/8/18

Abstract:
 this model will serve the photo comment object

*/

import Foundation

final class PhotoComment: NSObject {
    var content: String?
    var author: String?
    var date: Date?
    var validated: Bool = false
    
    var formattedDate: String {
        guard let date = date else {
            return "--"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy hh:mm a"
        return formatter.string(from: date)
    }
    
    required init(_ dictionary: [String: AnyObject]) {
        super.init()
        content = dictionary["comment"] as? String
        author = dictionary["author"] as? String
        if let timestampString = dictionary["timestamp"] as? String, let timestamp = Double(timestampString) {
            date = Date(timeIntervalSince1970: timestamp)
        }
        if let isValidated = dictionary["isValidated"] as? Bool {
            validated = isValidated
        }
    }
}
