//
/*
Photo.swift
Created on: 23/8/18

Abstract:
 this will be the information of each photos

*/

import Foundation

final class Photo: NSObject {
    
    var id: String?
    
    // storage URL
    var url: String?

    var name: String?
    
    // Story of the pic.
    var story: String?
    
    
    init(_ dictionary: [String: AnyObject]) {
        super.init()
        id = dictionary["id"] as? String
        url = dictionary["url"] as? String
        name = dictionary["name"] as? String
        story = dictionary["story"] as? String
    }
}
