//
//  AppDelegate.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var filterModel:FilterModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.FIRST_TIME_LOGIN) {
            // First time logging in - save the Aug 23th, 2018 time stamp hardcoded
            UserDefaults.standard.set(Constants.AUG_23_2018_TIMESTAMP,
                                      forKey: Constants.UserDefaultsKeys.REQUESTS_LAST_UPDATED_TIME)
            UserDefaults.standard.synchronize()
        }
        FirebaseApp.configure()
        FirebaseAPIConfigure.shared.configure()
        return true
    }
}

