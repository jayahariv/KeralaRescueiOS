//
/*
ContactsListViewController.swift
Created on: 24/8/18

Abstract:
 this will show the list of contacts for each section

*/

import UIKit

final class ContactsListViewController: UIViewController {
    
    var contacts = [Contact]()
    var departmentName: String!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    /// PRIVATE
    private struct C {
        static let cellId = "contactsListCell"
    }

    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: Helper methods

extension ContactsListViewController {
    func configureUI() {
        title = departmentName
        tableView.tableFooterView = UIView()
    }
}

extension ContactsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.cellId)
        let contact = contacts[indexPath.row]
        cell?.textLabel?.text = contact.name
        cell?.detailTextLabel?.text = contact.numbers?.first
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        let alert = UIAlertController(title: "Select the number to call", message: nil, preferredStyle: .actionSheet)
        for number in contact.numbers ?? [] {
            alert.addAction(UIAlertAction(title: number, style: .default, handler: { (_) in
                Utility.call(number)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
