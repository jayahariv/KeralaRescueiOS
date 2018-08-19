//
/*
ResultOptimizer.swift
Created on: 8/17/18

Abstract:
 this will optmize the result from the server.

*/

import Foundation

enum RequestType {
    case food
    case water
    case medicine
    case clothes
}

final class ResultOptimizer: NSObject {
    
    private static var instance = ResultOptimizer()
    
    static var shared: ResultOptimizer {
        return instance
    }
    
    var locations = [String: String]()
    var filtered = [String: RequestModel]()
    var forFood = [RequestModel]()
    var forWater = [RequestModel]()
    var forMedicine = [RequestModel]()
    var forClothes = [RequestModel]()
    
    func save(_ list: [RequestModel]) {
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
            
            guard
                request.needmed ||
                request.needfood ||
                request.needcloth ||
                request.needwater ||
                (request.needothers != nil) ||
                request.needrescue ||
                request.needtoilet ||
                request.needkit_util
            else {
                continue;
            }
            
            if request.needfood {
                forFood.append(request)
            }
            
            if request.needwater {
                forWater.append(request)
            }
            
            if request.needmed {
                forMedicine.append(request)
            }
            
            if request.needcloth {
                forClothes.append(request)
            }
            
            filtered[phone] = request
            locations[locationName] = phone
            
        }
        
        print("optmized: \(list.count - filtered.values.count)")
    }
    
    func getRequests( _ type: RequestType) -> [RequestModel]{
        switch type {
        case .food:
            return forFood
        case .water:
            return forWater
        case .medicine:
            return forMedicine
        case .clothes:
            return forClothes
        }
    }
}
