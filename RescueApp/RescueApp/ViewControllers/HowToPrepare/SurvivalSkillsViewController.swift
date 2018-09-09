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
    var topic: DisasterTopic!
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
        title = topic.title
    }
}

// MARK: SurvivalSkillsViewController -> UITableViewDataSource

extension SurvivalSkillsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return topic.situations.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topic.situations[section].skills.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.TABLEVIEW_CELL)
        let indexLabel = cell?.viewWithTag(1) as! UILabel
        indexLabel.text = "\(indexPath.row + 1)."
        let content = cell?.viewWithTag(2) as! UILabel
        content.text = topic.situations[indexPath.section].skills[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return topic.situations[section].title
    }
}
