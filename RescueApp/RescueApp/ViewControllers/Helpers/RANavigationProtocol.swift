//
//  RANavigationProtocol.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 9/1/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit

protocol RANavigationProtocol {}

extension RANavigationProtocol where Self: UIViewController {
    func configureNavigationBar(_ color: UIColor) {
        navigationController?.navigationBar.barTintColor = color
        if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = color
        }
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}
