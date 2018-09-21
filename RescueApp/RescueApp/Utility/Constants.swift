//
/*
Constants.swift
Created on: 21/8/18

Abstract:
 this will be shared constants values store

*/

import Foundation

struct Constants {
    struct UserDefaultsKeys {
        static let REQUESTS_LAST_UPDATED_TIME = "requests_last_updated_time"
        static let RELIEF_CAMPS_LAST_UPDATED_TIME = "relief_camps_last_updated_time"
        static let FIRST_TIME_LOGIN = "firstTimeLoggedIn"
        static let DANGER_NEED_HELP_MESSAGE = "need_help_in_danger_message"
        static let MARK_AS_SAFE_MESSAGE = "mark_as_safe_message"
        static let CAN_LOCATION_SHARED = "can_location_shared"
    }
    
    static let AUG_23_2018_TIMESTAMP: TimeInterval = 1534982400
    static let DAY_IN_SECONDS = TimeInterval(24 * 60 * 60)
    static let DANGER_NEED_HELP_MESSAGE = "Please help me, I am in danger"
    static let MARK_AS_SAFE_MESSAGE = "I am safe here."
}
