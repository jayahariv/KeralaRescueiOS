//
/*
SurvivalSkills.swift
Created on: 2/9/18

Abstract:
 Each disaster has multiple periods, like before, after, & during a disaster.

*/

import Foundation

final class DisasterPeriod: NSObject {
    var title: String?
    var situations = [DisasterSituation]()
    
    required init(_ title: String, info: [String: AnyObject]) {
        super.init()
        self.title = title
        var tempSituation = [DisasterSituation]()
        for situationJson in info.values {
            let title = situationJson["title"] as! String
            let details = situationJson["details"] as! [String]
            let sort = situationJson["sort"] as! Int
            let situationModel = DisasterSituation(title, details: details, sort: sort)
            tempSituation.append(situationModel)
        }
        tempSituation.sort { (a, b) -> Bool in
            return a.sort < b.sort
        }
        situations = tempSituation
    }
}

final class DisasterSituation: NSObject {
    var title: String?
    var skills = [String]()
    var sort: Int = 0
    
    required init(_ title: String, details: [String], sort: Int) {
        super.init()
        self.title = title
        skills = details
        self.sort = sort
    }
}
