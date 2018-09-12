//
/*
EmergencySOSViewController.swift
Created on: 12/9/18

Abstract:
 self descriptive

*/

import UIKit

final class EmergencySOSViewController: UIViewController, RANavigationProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
    }
}

private extension EmergencySOSViewController {
    func configureUIFromViewDidLoad() {
        configureNavigationBar(RAColorSet.RED)
    }
}
