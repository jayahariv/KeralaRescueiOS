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
    
    required init(_ name: String, info: [String: AnyObject]) {
        super.init()
        title = name
    }
}

final class DisasterSituation: NSObject {
    var title: String?
    var skills = [SurvivalSkill]()
}

final class SurvivalSkill: NSObject {
    var details: String?
}
