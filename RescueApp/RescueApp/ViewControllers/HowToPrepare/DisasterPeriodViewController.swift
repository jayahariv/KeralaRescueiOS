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
    @IBOutlet private weak var courtesyLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    private var ref: DatabaseReference?
    private var disaster: Disaster?
    /// StringConstants in this file.
    private struct C {
        struct FIREBASE_KEYS {
            static let ROOT = "prepare/flood"
            static let TITLE = "title"
            static let DESCRIPTION = "description"
            static let TOPICS = "topics"
            static let INFO = "info"
        }
        static let CELL_ID = "disasterPeriodTableCell"
        static let TITLE = "Prepare"
        static let SEGUE_TO_SURVIVAL_SKILLS = "segueToSurvivalSkillsViewController"
        static let COURTESY_LABEL = "Courtesy: getprepared.gc.ca, disastersupplycenter.com, sdma.kerala.gov.in"
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        if ApiClient.isConnected {
            fetchSurvivalSkillsFromFirebase()
        } else {
            fetchLocalSurvivalSkills()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.SEGUE_TO_SURVIVAL_SKILLS {
            let vc = segue.destination as! SurvivalSkillsViewController
            vc.topic = sender as! DisasterTopic
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
        navigationItem.backBarButtonItem = UIBarButtonItem()
        courtesyLabel.text = C.COURTESY_LABEL
    }
    
    /**
     loads the prepration data from Firebase
     
     */
    func fetchSurvivalSkillsFromFirebase() {
        ref = Database.database().reference()
        ref?.child(C.FIREBASE_KEYS.ROOT).observe(DataEventType.value, with: { [weak self] (snapshot) in
            self?.parsePrepareFloodResponse(snapshot.value as? [String: AnyObject] ?? [:])
        })
    }
    
    /**
     fetch the survival skills from locally
     
     */
    func fetchLocalSurvivalSkills() {
        if
            let path = Bundle.main.path(forResource: APIConstants.PLIST_KEYS.NAME, ofType: "plist"),
            let myDict = NSDictionary(contentsOfFile: path),
            let json = myDict["survival_skills_flood"] as? String
        {
            let data = json.data(using: .utf8)
            do {
                if let response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] {
                    parsePrepareFloodResponse(response)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func parsePrepareFloodResponse(_ dictionary: [String: AnyObject]) {
        disaster = Disaster(dictionary)
        refreshUI()
    }

    func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            self?.title = self?.disaster?.title
            self?.descriptionLabel.text = self?.disaster?.desc
            self?.tableView.reloadData()
        }
    }
}

// MARK: DisasterPeriodViewController -> UITableViewDataSource, UITableViewDelegate

extension DisasterPeriodViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disaster?.topics.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: C.CELL_ID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: C.CELL_ID)
        }
        let topic = disaster?.topics[indexPath.row]
        cell?.textLabel?.text = topic?.title
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: C.SEGUE_TO_SURVIVAL_SKILLS, sender: disaster?.topics[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TAKE ACTION"
    }
}

