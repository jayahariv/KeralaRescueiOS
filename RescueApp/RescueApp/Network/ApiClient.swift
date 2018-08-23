//
//  ApiClient.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

typealias IndividualRequestsCompletionHandler = (_ requests: [RequestModel]) -> Void
typealias ReliefCampsCompletionHandler = (_ requests: [ReliefCamp]) -> Void


import Foundation
import CouchbaseLiteSwift
import Reachability

/**
 These are used to get each end point with different types.
    For example individual request with offline data, you can pass the offline type in the method. or if we need online
 specific data, pass in online
 */
enum ApiClientRequestType {
    case regular // this will return the offline first and if not offline, online and if not online, cache data.
    case offline
    case online
}

final class ApiClient: NSObject {
    private static let instance = ApiClient()
    private let defaultSession = URLSession(configuration: .default)
    private let database = try? Database(name: "RescueApp")
    
    static var shared: ApiClient {
        return instance
    }
    
    // MARK: PUBLIC METHODS
    
    /**
     this will fetch the individual requests and return via completion handler
     
     - parameters:
         - type: ApiClientRequestType, whether caller needs online, offline or regular data(if offline, returns it, else get the online).
         - completion: self-descriptive
     */
    func getIndividualRequests(_ type: ApiClientRequestType, completion: @escaping IndividualRequestsCompletionHandler) {
        switch type {
        case .offline:
            completion(getOfflineResourceNeeds())
        case .online:
            getOnlineResourceNeeds(completion: completion)
        case .regular:
            if let doc = database?.document(withID: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY) {
                let str = doc.string(forKey: APIConstants.REQUESTS_OFFLINE_SAVE_KEY)
                if str != nil {
                    return completion(getOfflineResourceNeeds())
                }
                
            } else if let reachablity = Reachability(hostname: APIConstants.URL.INDIVIDUAL_REQUESTS), reachablity.connection != .none {
                getOnlineResourceNeeds(completion: completion)
                return
            }
            
            // fetch the locally saved data
            fetchFileDataAndSave()
            
            completion(getOfflineResourceNeeds())
        }
    }
    
    /**
     returns the relief camp data
     
     - parameters:
         - type: ApiClientRequestType, whether caller needs online, offline or regular data(if offline, returns it, else get the online).
         - completion: self-descriptive
     */
    func getReliefCamps(_ type: ApiClientRequestType, completion: @escaping ReliefCampsCompletionHandler) {
        switch type {
        case .offline:
            // TODO: get the offline data
            completion(getOfflineReliefCamps())
        case .online:
            getOnlineReliefCamps(completion)
        case .regular:
            if let doc = database?.document(withID: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY) {
                let str = doc.string(forKey: APIConstants.RELIEF_CAMPS_OFFLINE_SAVE_KEY)
                if str != nil {
                    return completion([])
                }
                
            } else if let reachablity = Reachability(hostname: APIConstants.URL.RELIEF_CAMPS), reachablity.connection != .none {
                getOnlineReliefCamps(completion)
                return
            }
            
            fetchReliefCampFileDataAndSave()
            
            completion(getOfflineReliefCamps())
        }
    }
}

// MARK: INDIVIDUAL REQUESTS METHODS

private extension ApiClient {
    func fetchFileDataAndSave() {
        if let path = Bundle.main.path(forResource: APIConstants.PLIST_KEYS.NAME, ofType: "plist"),
            let myDict = NSDictionary(contentsOfFile: path),
            let json = myDict[APIConstants.PLIST_KEYS.INDIVIDUAL_REQUESTS] as? String
        {
            let doc = MutableDocument(id: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY)
            doc.setString(json, forKey: APIConstants.REQUESTS_OFFLINE_SAVE_KEY)
            try? database?.saveDocument(doc)
        }
    }
    
    func getOfflineResourceNeeds() -> [RequestModel] {
        guard let db = database else {
            return []
        }
        
        let decoder = JSONDecoder()
        let document = db.document(withID: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY)
        if let documentData = document?.string(forKey: APIConstants.REQUESTS_OFFLINE_SAVE_KEY)?.data(using: .utf8) {
            do {
                let requestsData = try decoder.decode(RequestsData.self, from: documentData)
                RAStore.shared.saveIndividualRequests(requestsData.data)
                return requestsData.data
            }
            catch {
                print(error)
            }
        }
        return []
    }
    
    func getOnlineResourceNeeds(completion: @escaping IndividualRequestsCompletionHandler) {
        guard let url = URL(string: APIConstants.URL.INDIVIDUAL_REQUESTS) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = APIConstants.API_REQUEST_TIMEOUT
        let dataTask = defaultSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            
            // TODO: Handle all error conditions
            
            func onError() {
                completion([])
                return
            }
            
            guard error == nil else {
                onError()
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                onError()
                return
            }
            
            guard let data = data else {
                onError()
                return
            }
            
            do {
                
                if let json = String(data: data, encoding: .utf8) {
                    let doc = MutableDocument(id: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY)
                    doc.setString(json, forKey: APIConstants.REQUESTS_OFFLINE_SAVE_KEY)
                    try? self?.database?.saveDocument(doc)
                }
                
                let decoder = JSONDecoder()
                let requestsData = try decoder.decode(RequestsData.self, from: data)
                
                // filter the result
                RAStore.shared.saveIndividualRequests(requestsData.data)
                
                // save last updated time
                let timestamp = Int(Date().timeIntervalSince1970)
                UserDefaults.standard.set(timestamp, forKey: Constants.UserDefaultsKeys.REQUESTS_LAST_UPDATED_TIME)
                
                completion(requestsData.data)
                
            } catch {
                print(error)
            }
            
            
        }
        dataTask.resume()
    }
}

// MARK: RELIEF CAMPS HELPER METHODS

private extension ApiClient {
    /**
     does the main API call, and handles the common HTTP errors
     
     - parameters:
        - completion handler:  self descriptive
     */
    func getOnlineReliefCamps(_ completion: @escaping ReliefCampsCompletionHandler) {
        guard let url = URL(string: APIConstants.URL.RELIEF_CAMPS) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = APIConstants.API_REQUEST_TIMEOUT
        let dataTask = defaultSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            
            // TODO: Handle all error conditions
            
            func onError() {
                completion([])
                return
            }
            
            guard error == nil else {
                onError()
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                onError()
                return
            }
            
            guard let data = data else {
                onError()
                return
            }
            
            do {
                
                if let json = String(data: data, encoding: .utf8) {
                    let doc = MutableDocument(id: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY)
                    doc.setString(json, forKey: APIConstants.RELIEF_CAMPS_OFFLINE_SAVE_KEY)
                    try? self?.database?.saveDocument(doc)
                }
                
                let decoder = JSONDecoder()
                let reliefCampsDictionary = try decoder.decode(ReliefCampsDictionary.self, from: data)
                
                // filter the result
                RAStore.shared.saveReliefCamps(reliefCampsDictionary.data)
                
                // save last updated time
                let timestamp = Int(Date().timeIntervalSince1970)
                UserDefaults.standard.set(timestamp, forKey: Constants.UserDefaultsKeys.RELIEF_CAMPS_LAST_UPDATED_TIME)
                
                completion(reliefCampsDictionary.data)
                
            } catch {
                print(error)
            }
            
            
        }
        dataTask.resume()
    }
    
    /**
     self descriptive - offline camp relief objects
 
     - returns: list of relief camps
     - todo:
        - refactor and get the keys to return all offline data from couchbase
     */
    func getOfflineReliefCamps() -> [ReliefCamp] {
        guard let db = database else {
            return []
        }
        
        let decoder = JSONDecoder()
        let document = db.document(withID: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY)
        if let documentData = document?.string(forKey: APIConstants.RELIEF_CAMPS_OFFLINE_SAVE_KEY)?.data(using: .utf8) {
            do {
                let campsData = try decoder.decode(ReliefCampsDictionary.self, from: documentData)
                RAStore.shared.saveReliefCamps(campsData.data)
                return campsData.data
            }
            catch {
                print(error)
            }
        }
        return []
    }
    
    /**
     this will fetch the data from plist data on Aug 23, 2018
     
     - todo: refactor and pass a key to get data for both
     */
    func fetchReliefCampFileDataAndSave() {
        if let path = Bundle.main.path(forResource: APIConstants.PLIST_KEYS.NAME, ofType: "plist"),
            let myDict = NSDictionary(contentsOfFile: path),
            let json = myDict[APIConstants.PLIST_KEYS.RELIEF_CAMP_KEY] as? String
        {
            let doc = MutableDocument(id: APIConstants.COUCHBASE_OFFLINE_SAVE_ROOT_KEY)
            doc.setString(json, forKey: APIConstants.REQUESTS_OFFLINE_SAVE_KEY)
            try? database?.saveDocument(doc)
        }
    }
    
}
