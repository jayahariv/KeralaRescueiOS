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
            static let ROOT = "how_to_prepare"
            static let SECTION_NAME = "sections"
            static let SECTION_DETAIL = "section_details"
        }
        static let CELL_ID = "howToPrepareTableCell"
        static let TITLE = "How to Prepare"
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchHowToPrepareFromFirebase()
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
    func fetchHowToPrepareFromFirebase() {
        ref = Database.database().reference()
        ref?.child(C.FIREBASE_KEYS.ROOT).observe(DataEventType.value, with: { [weak self] (snapshot) in
            let howToPrepareGuides = snapshot.value as? [String: AnyObject] ?? [:]
            self?.howToPrepareSections = howToPrepareGuides[C.FIREBASE_KEYS.SECTION_NAME] as? [String: String] ?? [:]
            if let names = self?.howToPrepareSections.keys {
                self?.howToPrepareSectionNames = Array(names)
            }
            
            let details = howToPrepareGuides[C.FIREBASE_KEYS.SECTION_DETAIL] as? [String: AnyObject] ?? [:]
            for sectionDetail in details {
                if let value = sectionDetail.value as? [String: String] {
                    var howToPrepareGuides = [HowToPrepareModel]()
                    for prepareGuide in value {
                        let prepareModel = HowToPrepareModel(prepareGuide.key, info: prepareGuide.value)
                        howToPrepareGuides.append(prepareModel)
                    }
                    self?.howToPrepareSectionDetails[sectionDetail.key] = howToPrepareGuides
                }
            }
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
        return howToPrepareSectionNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_ID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: C.CELL_ID)
        }
        let contact = howToPrepareSections[howToPrepareSectionNames[indexPath.row]]
        cell?.textLabel?.text = contact
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // implement
    }
}

