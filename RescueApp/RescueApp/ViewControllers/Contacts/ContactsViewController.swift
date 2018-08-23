//
/*
ContactsViewController.swift
Created on: 23/8/18

Abstract:
 this class will show all the contact lists

*/

import UIKit

final class ContactsViewController: UIViewController {
    
    // MARK: Properties
    /// PRIVATE
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var infoTitlaLabel: UILabel!
    private var contacts = [String]()
    private struct C {
        static let tableCellId = "contactsCell"
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: Helper methods

private extension ContactsViewController {
    /**
     configure all UI items inside this, once its loaded.
     
     */
    func configureUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    /**
     load the contacts list from firebase
     
     - todo: implementation not done
     */
    func loadFromFirebase() {
        // TODO: implement
    }
    
    /**
     refreshes the UI, especially tableview
     
     */
    func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: ContactsViewController -> UITableViewDataSource

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.tableCellId)
        if cell == nil {
            cell = UITableViewCell(style: .value2, reuseIdentifier: C.tableCellId)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let phone = "" // TODO: get the phone number
        Utility.call(phone)
    }
}
