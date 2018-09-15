//
/*
SafetyCheckSettingsViewController.swift
Created on: 15/9/18

Abstract:
 this will include the safety check settings
 - add emergency contacts
 - set the message
 - enable location sharing
 - see the list of emergency contacts

*/

import UIKit

final class SafetyCheckSettingsViewController: UIViewController {
    
    // MARK: Properties
    /// PRIVATE
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var canShareLocationSwitch: UISwitch!
    private struct C {
        static let CELL_ID = "safetyCheckCellID"
        static let TITLE = "Emergency Settings"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
        addTapToHideKeyboardGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveLocationPreference()
    }
}

private extension SafetyCheckSettingsViewController {
    func configureUIFromViewDidLoad() {
        title = C.TITLE
        textView.text = fetchCustomDangerMessage() ?? Constants.DANGER_NEED_HELP_MESSAGE
        canShareLocationSwitch.isOn = fetchCanShareLocation()
    }
    
    func addTapToHideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
    
    func fetchCustomDangerMessage() -> String? {
        if let danger = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.DANGER_NEED_HELP_MESSAGE) {
            return danger
        }
        return nil
    }
    
    func saveDangerMessage(_ message: String) {
        guard message != fetchCustomDangerMessage() else {
            return
        }
        UserDefaults.standard.set(message, forKey: Constants.UserDefaultsKeys.DANGER_NEED_HELP_MESSAGE)
    }
    
    func fetchCanShareLocation() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.CAN_LOCATION_SHARED)
    }
    
    func saveLocationPreference() {
        guard canShareLocationSwitch.isOn != fetchCanShareLocation() else {
            return
        }
        UserDefaults.standard.set(canShareLocationSwitch.isOn, forKey: Constants.UserDefaultsKeys.CAN_LOCATION_SHARED)
    }
}


extension SafetyCheckSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_ID)
        cell?.selectionStyle = .none
        cell?.textLabel?.text = "NameOfContact"
        cell?.detailTextLabel?.text = "+91-1234567890"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Contacts"
    }
}

extension SafetyCheckSettingsViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        saveDangerMessage(textView.text)
        return true
    }
}
