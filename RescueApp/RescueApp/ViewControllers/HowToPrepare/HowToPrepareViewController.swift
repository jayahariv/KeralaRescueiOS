//
//  HowToPrepareViewController.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 9/1/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit
import FirebaseDatabase

final class HowToPrepareViewController: UIViewController, RANavigationProtocol {
    
    // MARK: Properties
    /// PRIVATE
    @IBOutlet private weak var tableView: UITableView!
    private var howToPrepareSectionNames = [String]()
    private var howToPrepareSections = [String: String]()
    private var howToPrepareSectionDetails = [String: [HowToPrepareModel]]()
    private var ref: DatabaseReference?
    /// StringConstants in this file.
    private struct C {
        struct FIREBASE_KEYS {
            static let ROOT = "survival_skills_flood"
            static let TITLE = "title"
            static let INFO = "info"
        }
        static let CELL_ID = "howToPrepareTableCell"
        static let TITLE = "Prepare for a Flood"
    }
    private var periods = [DisasterPeriod]()

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchSurvivalSkillsFromFirebase()
    }
}

// MARK: Helper methods

extension HowToPrepareViewController {
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

// MARK: HowToPrepareViewController -> UITableViewDataSource, UITableViewDelegate

extension HowToPrepareViewController: UITableViewDataSource, UITableViewDelegate {
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
        // implement
    }
}

