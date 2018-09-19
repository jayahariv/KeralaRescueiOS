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
import ContactsUI
import CouchbaseLiteSwift
import CoreLocation

final class SafetyCheckSettingsViewController: UIViewController {
    
    // MARK: Properties
    /// IBOUTLETS
    @IBOutlet private weak var helpNeededTextView: UITextView!
    @IBOutlet private weak var markAsSafeTextView: UITextView!
    @IBOutlet private weak var canShareLocationSwitch: UISwitch!
    @IBOutlet private weak var contactsTableView: UITableView!
    @IBOutlet private weak var noContactsWarningLabel: UILabel!
    @IBOutlet private weak var addRecipientsButton: UIButton!
    /// iVARs
    private var contacts = [EmergencyContact]()
    private let locationManager = CLLocationManager()
    private struct C {
        static let CELL_ID = "safetyCheckCellID"
        static let TITLE = "Emergency Settings"
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
        addTapToHideKeyboardGesture()
        fetchContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarColor(RAColorSet.RED)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveLocationPreference()
    }
    
    // MARK: Button Actions
    
    @IBAction func onAddRecipients(_ sender: Any) {
        let contactPicker = CNContactPickerViewController(nibName: nil, bundle: nil)
        contactPicker.delegate = self
        present(contactPicker, animated: true) { [weak self] in
            self?.setStatusBarColor(RAColorSet.STATUS_BAR_COLOR)
        }
    }
    
    @IBAction func onToggleLocationSwitch(_ sender: Any) {
        saveLocationPreference()
    }
}

private extension SafetyCheckSettingsViewController {
    func configureUIFromViewDidLoad() {
        title = C.TITLE
        
        helpNeededTextView.text =
            fetchCustomMessage(Constants.UserDefaultsKeys.DANGER_NEED_HELP_MESSAGE) ?? Constants.DANGER_NEED_HELP_MESSAGE
        markAsSafeTextView.text =
            fetchCustomMessage(Constants.UserDefaultsKeys.MARK_AS_SAFE_MESSAGE) ?? Constants.MARK_AS_SAFE_MESSAGE
        canShareLocationSwitch.isOn = fetchCanShareLocation()
        addRecipientsButton.backgroundColor = RAColorSet.WARNING_RED
        configureContactsUI(contacts.count > 0)
    }
    
    func fetchContacts() {
        contacts = EmergencyContactUtil.fetchContacts()
        refreshContacts()
    }
    
    func refreshContacts() {
        configureContactsUI(contacts.count > 0)
        contactsTableView.reloadData()
    }
    
    func addTapToHideKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        helpNeededTextView.resignFirstResponder()
        markAsSafeTextView.resignFirstResponder()
    }
    
    func fetchCustomMessage(_ key: String) -> String? {
        if let danger = UserDefaults.standard.string(forKey: key) {
            return danger
        }
        return nil
    }
    
    func saveMessage(_ message: String, key: String) {
        guard message != fetchCustomMessage(key) else {
            return
        }
        UserDefaults.standard.set(message, forKey: key)
    }
    
    func fetchCanShareLocation() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.CAN_LOCATION_SHARED)
    }
    
    func saveLocationPreference() {
        guard canShareLocationSwitch.isOn != fetchCanShareLocation() else {
            return
        }
        UserDefaults.standard.set(canShareLocationSwitch.isOn, forKey: Constants.UserDefaultsKeys.CAN_LOCATION_SHARED)
        if canShareLocationSwitch.isOn {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func configureContactsUI(_ contactsPresent: Bool) {
        contactsTableView.isHidden = !contactsPresent
        noContactsWarningLabel.isHidden = contactsPresent
    }
    
    func setStatusBarColor(_ color: UIColor) {
        if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = color
        }
    }
    
    func removeAllContacts() {
        do {
            let database = try Database(name: "RescueApp")
            let doc = MutableDocument(id: APIConstants.CBL_KEYS.EMERGENCY_CONTACTS_ROOT_KEY)
            try database.saveDocument(doc)
        } catch {
            print("test")
        }
    }
}


extension SafetyCheckSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_ID)
        cell?.selectionStyle = .none
        let contact = contacts[indexPath.row]
        cell?.textLabel?.text = contact.displayName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Contacts"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

extension SafetyCheckSettingsViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        saveMessage(textView.text,
                    key: textView == helpNeededTextView
                        ? Constants.UserDefaultsKeys.DANGER_NEED_HELP_MESSAGE
                        : Constants.UserDefaultsKeys.MARK_AS_SAFE_MESSAGE)
        return true
    }
}

extension SafetyCheckSettingsViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        var tempContacts = [EmergencyContact]()
        for contact in contacts {
            let contact = EmergencyContact.init(contact)
            tempContacts.append(contact)
        }
        
        removeAllContacts()
        for contact in tempContacts {
            contact.save()
        }
        
        self.contacts = tempContacts
        refreshContacts()
    }
}
