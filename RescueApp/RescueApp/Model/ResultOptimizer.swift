//
/*
ResultOptimizer.swift
Created on: 8/17/18

Abstract:
 this will optmize the result from the server.

*/

import Foundation

final class ResultOptimizer: NSObject {
    
    private static var instance = ResultOptimizer()
    
    static var shared: ResultOptimizer {
        return instance
    }
    
    var locations = [String: String]()
    var filtered = [String: RequestModel]()
    
    func filter(_ list: [RequestModel]) {
        
        for request in list {
            
            guard let phone = request.requestee_phone else {
                continue
            }
            
            guard let requestee = request.requestee, !requestee.lowercased().contains("test")  else {
                continue
            }
            
            guard filtered[phone] == nil else {
                continue
            }
            
            guard request.status == "new" else {
                continue
            }
            
            guard let locationName = request.location else {
                continue;
            }
            
            filtered[phone] = request
            locations[locationName] = phone
            
        }
    }
}
