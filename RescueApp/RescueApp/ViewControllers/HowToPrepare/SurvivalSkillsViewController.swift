//
/*
SurvivalSkillsViewController.swift
Created on: 2/9/18

Abstract:
 this will show the list of survival skills

*/

import UIKit

final class SurvivalSkillsViewController: UIViewController {
    
    // MARK: Properties
    ///PUBLIC
    var situations = [DisasterSituation]()
    ///PRIVATE
    private struct C {
        static let TABLEVIEW_CELL = "survivalSkillsCell"
        static let TITLE = "Survival Skills"
    }
    

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

extension SurvivalSkillsViewController {
    /**
     configure UI once when view is loaded
     
     */
    func configureUI() {
        title = C.TITLE
    }
}

// MARK: SurvivalSkillsViewController -> UITableViewDataSource

extension SurvivalSkillsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return situations.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return situations[section].skills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.TABLEVIEW_CELL)
        cell?.textLabel?.text = situations[indexPath.section].skills[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return situations[section].title
    }
}
