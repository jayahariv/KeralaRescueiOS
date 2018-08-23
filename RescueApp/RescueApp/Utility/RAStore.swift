//
/*
RAStore.swift
Created on: 8/17/18

Abstract:
 this class will be the singelton store!!!

*/

import Foundation

enum RequestType: String {
    case food = "Food"
    case water = "Water"
    case medicine = "Medicine"
    case clothes = "Clothes"
}

final class RAStore: NSObject {
    
    private static var instance = RAStore()
    
    static var shared: RAStore {
        return instance
    }
    
    /// MARK: INDIVIDUAL REQUESTS RELATED
    var locations = [String: String]()
    var filtered = [String: RequestModel]()
    var forFood = [RequestModel]()
    var forWater = [RequestModel]()
    var forMedicine = [RequestModel]()
    var forClothes = [RequestModel]()
    
    /// MARK: RELIFE CAMP RELATED
    var reliefcamps = [ReliefCamp]()
    
    /**
     save the individual requests list. it will optmize the result and filter the unwanted resulst before saving
     
     - parameters:
        - list: list of requests
     */
    func saveIndividualRequests(_ list: [RequestModel]) {
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
    
    // MARK: RELIEF CAMPS METHODS
    func saveReliefCamps(_ list: [ReliefCamp]) {
        reliefcamps = list
    }
    
    func getReliefCamps() -> [ReliefCamp] {
        return reliefcamps
    }
}
