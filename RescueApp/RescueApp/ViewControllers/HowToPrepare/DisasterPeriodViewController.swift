//
/*
 SurvivalSkillsViewController.swift
 Created on: 1/9/18
 
 Abstract:
 this will show disaster periods, like before, after, during disasters.
 
 */

import UIKit
import FirebaseDatabase

final class DisasterPeriodViewController: UIViewController, RANavigationProtocol {
    
    // MARK: Properties
    /// PRIVATE
    @IBOutlet private weak var tableView: UITableView!
    private var ref: DatabaseReference?
    private var periods = [DisasterPeriod]()
    /// StringConstants in this file.
    private struct C {
        struct FIREBASE_KEYS {
            static let ROOT = "survival_skills_flood"
            static let TITLE = "title"
            static let INFO = "info"
        }
        static let CELL_ID = "disasterPeriodTableCell"
        static let TITLE = "Prepare"
        static let SEGUE_TO_SURVIVAL_SKILLS = "segueToSurvivalSkillsViewController"
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchSurvivalSkillsFromFirebase()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.SEGUE_TO_SURVIVAL_SKILLS {
            let vc = segue.destination as! SurvivalSkillsViewController
            vc.situations = sender as! [DisasterSituation]
        }
    }
}

// MARK: Helper methods

extension DisasterPeriodViewController {
    /**
     configurs the UI once when view is loaded inside this method
     
     */
    func configureUI() {
        configureNavigationBar(RAColorSet.RED)
        tableView.tableFooterView = UIView()
        title = C.TITLE
    }
    
    /**
     loads the prepration data from Firebase
     
     */
    func fetchSurvivalSkillsFromFirebase() {
        ref = Database.database().reference()
        ref?.child(C.FIREBASE_KEYS.ROOT).observe(DataEventType.value, with: { [weak self] (snapshot) in
            let disasterStages = snapshot.value as? [String: AnyObject] ?? [:]
            var periods = [DisasterPeriod]()
            for stage in disasterStages.values {
                let title = stage[C.FIREBASE_KEYS.TITLE] as! String
                let info = stage[C.FIREBASE_KEYS.INFO] as! [String: AnyObject]
                let period = DisasterPeriod(title, info: info)
                periods.append(period)
            }
            self?.periods = periods
            self?.refreshUI()
        })
    }
    
    /**
     refreshes the UI to reflect the new data
     
     */
    func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: DisasterPeriodViewController -> UITableViewDataSource, UITableViewDelegate

extension DisasterPeriodViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_ID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: C.CELL_ID)
        }
        let disasterPeriod = periods[indexPath.row]
        cell?.textLabel?.text = disasterPeriod.title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: C.SEGUE_TO_SURVIVAL_SKILLS, sender: periods[indexPath.row].situations)
    }
}

