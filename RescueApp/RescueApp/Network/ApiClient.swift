//
//  ApiClient.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

typealias ResourceNeeds = () -> Void

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
    
    func getOfflineData(completion: @escaping ResourceNeeds) {
        getOfflineResourceNeeds(completion: completion)
    }
    
    func getResourceNeeds(completion: @escaping ResourceNeeds) {
        
        if let _ = database?.document(withID: "json") {
            getOfflineResourceNeeds(completion: completion)
            return
        } else {
            fetchFileDataAndSave()
            getOfflineResourceNeeds(completion: completion)
        }
    }
}

private extension ApiClient {
    
    func fetchFileDataAndSave() {
        if let path = Bundle.main.path(forResource: "Data", ofType: "plist"),
            let myDict = NSDictionary(contentsOfFile: path),
            let json = myDict["data"] as? String
        {
            let doc = MutableDocument(id: "json")
            doc.setString(json, forKey: "json")
            try? database?.saveDocument(doc)
        }
    }
    
    func getOfflineResourceNeeds(completion: @escaping ResourceNeeds) {
        guard let db = database else {
            return
        }
        
        let decoder = JSONDecoder()
        
        do {
            
            let document = db.document(withID: "json")
            
            if let documentData = document?.string(forKey: "json")?.data(using: .utf8) {
                
                let requests = try decoder.decode([RequestModel].self, from: documentData)
                
                ResultOptimizer.shared.save(requests)
            }
            
            completion()
            
        } catch {
            print(error)
        }
    }
    
    func getOnlineResourceNeeds(completion: @escaping ResourceNeeds) {
        guard let url = URL(string: APIConstants.RESOURCE_URL) else {
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 10
        let dataTask = defaultSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            
            // TODO: Handle all error conditions
            
            guard error == nil else {
                completion()
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion()
                return
            }
            
            guard let data = data else {
                completion()
                return
            }
            
            if let json = String(data: data, encoding: .utf8) {
                let doc = MutableDocument(id: "json")
                doc.setString(json, forKey: "json")
                try? self?.database?.saveDocument(doc)
            }
            
            let decoder = JSONDecoder()
            
            do {
                
                let requests = try decoder.decode([RequestModel].self, from: data)
                
                // filter the result
                ResultOptimizer.shared.save(requests)
                
                completion()
                
            } catch {
                print(error)
            }
        }
        dataTask.resume()
    }
}
