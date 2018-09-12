//
/*
 DisasterTopicsViewController.swift
 Created on: 1/9/18
 
 Abstract:
 this will show disaster topics, like before, after, during disasters.
 
 */

import UIKit
import FirebaseDatabase

final class DisasterTopicsViewController: UIViewController, RANavigationProtocol {
    
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
            static let ROOT_ENGLISH = "prepare/flood/english"
            static let ROOT_MALAYALAM = "prepare/flood/malayalam"
            static let TITLE = "title"
            static let DESCRIPTION = "description"
            static let TOPICS = "topics"
            static let INFO = "info"
        }
        static let CELL_ID = "disasterPeriodTableCell"
        static let TITLE = "Prepare"
        static let SEGUE_TO_SURVIVAL_SKILLS = "segueToSurvivalSkillsViewController"
        static let COURTESY_LABEL = "Courtesy: getprepared.gc.ca, disastersupplycenter.com, sdma.kerala.gov.in"
        static let PLIST_PREPARE_GUIDE_KEY = "prepare"
        static let TOPICS_HEADING = "TAKE ACTION"
    }
    private var language: Language = .english
    
    // SUPPORTED LANGUAGES
    enum Language {
        case english
        case malayalam
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
        if ApiClient.isConnected {
            fetchPrepareGuideFromFirebase(.english)
        } else {
            fetchPrepareGuideFromPLIST()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.SEGUE_TO_SURVIVAL_SKILLS {
            let vc = segue.destination as! SurvivalSkillsViewController
            vc.topic = sender as! DisasterTopic
        }
    }
    
    // MARK: Button Click
    @objc func onSelectLanguage() {
        let alert = UIAlertController(title: "Select language", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "English", style: .default, handler: { [weak self] (_) in
            self?.changeLanguage(.english)
        }))
        alert.addAction(UIAlertAction(title: "Malayalam", style: .default, handler: { [weak self] (_) in
            self?.changeLanguage(.malayalam)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Helper methods

private extension DisasterTopicsViewController {
    func configureUIFromViewDidLoad() {
        configureNavigationBar(RAColorSet.RED)
        tableView.tableFooterView = UIView()
        navigationItem.backBarButtonItem = UIBarButtonItem()
        courtesyLabel.text = C.COURTESY_LABEL
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: ImageName.LANGUAGE_ICON),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(onSelectLanguage))
    }
    
    func fetchPrepareGuideFromFirebase(_ language: Language) {
        Overlay.shared.show()
        ref = Database.database().reference()
        ref?.child(language == .english ? C.FIREBASE_KEYS.ROOT_ENGLISH : C.FIREBASE_KEYS.ROOT_MALAYALAM)
            .observe(DataEventType.value, with: { [weak self] (snapshot) in
                Overlay.shared.remove()
                self?.parseJSONPrepareFloodResponse(snapshot.value as? [String: AnyObject] ?? [:])
        })
    }
    
    func fetchPrepareGuideFromPLIST() {
        if
            let path = Bundle.main.path(forResource: APIConstants.PLIST_KEYS.NAME, ofType: "plist"),
            let myDict = NSDictionary(contentsOfFile: path),
            let json = myDict[C.PLIST_PREPARE_GUIDE_KEY] as? String
        {
            let data = json.data(using: .utf8)
            showDataInUI(data)
        }
    }
    
    func showDataInUI(_ data: Data?) {
        guard let data = data else {
            return
        }
        do {
            if let response = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                parseJSONPrepareFloodResponse(response)
            }
        } catch {
            print(error)
        }
    }
    
    func parseJSONPrepareFloodResponse(_ dictionary: [String: AnyObject]) {
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
    
    func changeLanguage(_ language: Language) {
        fetchPrepareGuideFromFirebase(language)
    }
}

// MARK: DisasterPeriodViewController -> UITableViewDataSource, UITableViewDelegate

extension DisasterTopicsViewController: UITableViewDataSource, UITableViewDelegate {
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
        return C.TOPICS_HEADING
    }
}

