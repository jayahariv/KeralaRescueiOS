//
//  HowToPrepareViewController.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 9/1/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit

final class HowToPrepareViewController: UIViewController, RANavigationProtocol {

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: Helper methods

extension HowToPrepareViewController {
    func configureUI() {
        configureNavigationBar(RAColorSet.RED)
    }
}
