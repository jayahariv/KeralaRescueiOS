//
/*
RequestsDictionary.swift
Created on: 8/19/18

Abstract:
 requests data model

*/

import Foundation

final class RequestsData: NSObject, Codable {
    var data = [RequestModel]()
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}
