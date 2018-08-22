//
/*
DistrictListViewController.swift
Created on: 21/8/18

Abstract:
 this will be a class which will show list of districts when presented. On setting delegate will get the selected
 district enum

*/

import UIKit

protocol DistrictListProtocol {
    func didSelectDistricts(_ districts: [District])
}

final class DistrictListViewController: UIViewController {
    
    // MARK: Properties
    /// PUBLIC
    var delegate: DistrictListProtocol?
    
    /// PRIVATE
    private var selectedDistricts = [Bool](repeating: false, count: 14)
    @IBOutlet private weak var tableView: UITableView!
    private struct C {
        static let cellId = "districtCell"
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    
    // MARK: Button Actions
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDone(_ sender: Any) {
        let result = District.allValues.enumerated().filter { (offset, district) -> Bool in
            return selectedDistricts[offset]
            }.map { (offset, district) -> District in
                return district
            }
        
        delegate?.didSelectDistricts(result)
        dismiss(animated: true, completion: nil)
    }
}


// MARK: Helper methods

private extension DistrictListViewController {
    /**
     this method is used to configure UI elements once the view is loaded
     
     */
    func configureUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
}

extension DistrictListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return District.allValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: C.cellId)
        }
        cell?.textLabel?.text = District.allValues[indexPath.row].rawValue
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDistricts[indexPath.row] = !selectedDistricts[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = selectedDistricts[indexPath.row] ? .checkmark: .none
    }
}
