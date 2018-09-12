//
/*
EmergencySOSViewController.swift
Created on: 12/9/18

Abstract:
 self descriptive

*/

import UIKit
import AVFoundation

final class EmergencySOSViewController: UIViewController, RANavigationProtocol {
    
    // MARK: Properties
    private let toolsSections = ["Flashlight", "Strobe Light", "Alarm"]
    private let safetySections = ["I'm safe", "I need help"]
    private struct C {
        static let TITLE = "Emergency/SOS"
        static let CELL_WITH_SWITCH_ID = "SOSCellWithSwitch"
        static let BASIC_CELL_ID = "SOSBasicCell"
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
    }
    
    func onToggleFlashlight() {
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                let torchOn = !device.isTorchActive
                try device.setTorchModeOn(level: 1.0)
                device.torchMode = torchOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("error")
            }
        }
    }
    
    func onToggleStrobeLight() {
        // implement
    }
}

// MARK: Helper Methods

private extension EmergencySOSViewController {
    func configureUIFromViewDidLoad() {
        configureNavigationBar(RAColorSet.RED)
        title = C.TITLE
    }
}

extension EmergencySOSViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // TODO: Only keeping tools currently
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = toolsSections.count
        } else if section == 1 {
            rowCount = safetySections.count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_WITH_SWITCH_ID)
            let label = cell.viewWithTag(1) as! UILabel
            label.text = toolsSections[indexPath.row]
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: C.BASIC_CELL_ID)
            cell?.textLabel?.text = safetySections[indexPath.row]
        default:
            abort()
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String!
        if section == 0 {
            title = "Emergency Tools"
        } else if section == 1 {
            title = "Safety Check"
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let cell = tableView.cellForRow(at: indexPath)
            let toggleSwitch = cell?.viewWithTag(2) as! UISwitch
            toggleSwitch.isOn = !toggleSwitch.isOn
            onToggleFlashlight()
        default:
            onToggleStrobeLight()
        }
    }
}