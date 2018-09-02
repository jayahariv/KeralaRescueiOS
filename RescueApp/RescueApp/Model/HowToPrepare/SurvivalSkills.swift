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
            let situationModel = DisasterSituation(title, details: details)
            tempSituation.append(situationModel)
        }
        situations = tempSituation
    }
}

final class DisasterSituation: NSObject {
    var title: String?
    var skills = [String]()
    
    required init(_ title: String, details: [String]) {
        super.init()
        self.title = title
//        var tempSkills = [String]()
//        for skill in details.values {
//            let skillString = skill as! String
//            tempSkills.append(skillString)
//        }
        skills = details
    }
}
