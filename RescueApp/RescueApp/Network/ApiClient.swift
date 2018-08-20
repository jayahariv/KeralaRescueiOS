//
//  ApiClient.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

typealias ResourceNeeds = (_ requests: [RequestModel]) -> Void

import Foundation
import Reachability
import CouchbaseLiteSwift

class ApiClient: NSObject {
    private static let instance = ApiClient()
    private let defaultSession = URLSession(configuration: .default)
    private let reachability = Reachability()!
    private let database = try? Database(name: "RescueApp")
    
    static var shared: ApiClient {
        return instance
    }
    
    // MARK: Get Public Methods
    
    /**
     gets the offline data
     
     - returns: array of requests
     */
    func getOfflineData() -> [RequestModel] {
        return getOfflineResourceNeeds()
    }
    
    /**
     get specifically the online data
     
     - parameters: completeion handler
     */
    func getOnlineData(completion: @escaping ResourceNeeds) {
        getOnlineResourceNeeds(completion: completion)
    }
    
    /**
     get offline data if present, else online data
     
     - parameters: completion handler
     */
    func getResourceNeeds(completion: @escaping ResourceNeeds) {
        
        let url = URL(string: APIConstants.RESOURCE_URL)
        if let doc = database?.document(withID: "json") {
            let str = doc.string(forKey: "json")
            if str != nil {
                return completion(getOfflineResourceNeeds())
            }
            
        } else if let reachable = (try? url?.checkResourceIsReachable()) ?? false, reachable {
            getOnlineResourceNeeds(completion: completion)
            return
        }
        
        // fetch the locally saved data
        fetchFileDataAndSave()
        
        completion(getOfflineResourceNeeds())
        
    }
}

private extension ApiClient {
    
    func fetchFileDataAndSave() {
        if let path = Bundle.main.path(forResource: "OfflineData", ofType: "plist"),
            let myDict = NSDictionary(contentsOfFile: path),
            let json = myDict["data"] as? String
        {
            let doc = MutableDocument(id: "json")
            doc.setString(json, forKey: "json")
            try? database?.saveDocument(doc)
        }
    }
    
    func getOfflineResourceNeeds() -> [RequestModel] {
        guard let db = database else {
            return []
        }
        
        let decoder = JSONDecoder()
        let document = db.document(withID: "json")
        if let documentData = document?.string(forKey: "json")?.data(using: .utf8) {
            do {
                let requestsData = try decoder.decode(RequestsData.self, from: documentData)
                ResultOptimizer.shared.save(requestsData.data)
                return requestsData.data
            }
            catch {
                print(error)
            }
        }
        return []
    }
    
    func getOnlineResourceNeeds(completion: @escaping ResourceNeeds) {
        guard let url = URL(string: APIConstants.RESOURCE_URL) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 10
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
            
            if let json = String(data: data, encoding: .utf8) {
                let doc = MutableDocument(id: "json")
                doc.setString(json, forKey: "json")
                try? self?.database?.saveDocument(doc)
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let requestsData = try decoder.decode(RequestsData.self, from: data)
                
                // filter the result
                ResultOptimizer.shared.save(requestsData.data)
                
                completion(requestsData.data)
                
            } catch {
                print(error)
            }
            
            
        }
        dataTask.resume()
    }
}
