//
/*
ReliefCampsDictionary.swift
Created on: 22/8/18

Abstract:
 Parent dictionary for Relief Camps

*/

import Foundation

final class ReliefCampsDictionary: NSObject, Codable {
    var data =  [ReliefCamp]()
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}
