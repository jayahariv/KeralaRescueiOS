//
/*
SurvivalSkills.swift
Created on: 2/9/18

Abstract:
 Each disaster has multiple periods, like before, after, & during a disaster.

*/

import Foundation

final class Disaster: NSObject {
    var title: String?
    var desc: String?
    var topics = [DisasterTopic]()
    
    required init(_ info: [String: AnyObject]) {
        super.init()
        title = info["title"] as? String
        desc = info["description"] as? String
        let topicsDictionary =  info["topics"] as! [String: AnyObject]
        var tempTopics = [DisasterTopic]()
        for topic in topicsDictionary.values {
            let dic = topic as! [String: AnyObject]
            let topic = DisasterTopic(dic)
            tempTopics.append(topic)
        }
        tempTopics.sort { (a, b) -> Bool in
            return a.sort < b.sort
        }
        topics = tempTopics
    }
}

final class DisasterTopic: NSObject {
    var title: String?
    var sort: Int = 0
    var desc: String?
    var situations = [DisasterSituation]()
    
    required init(_ info: [String: AnyObject]) {
        super.init()
        title = info["title"] as? String
        sort = info["sort"] as! Int
        let info = info["info"] as! [String: AnyObject]
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
