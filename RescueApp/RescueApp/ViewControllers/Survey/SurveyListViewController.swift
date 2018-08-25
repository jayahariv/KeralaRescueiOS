//
//  SurveyListViewController.swift
//  RescueApp
//
//  Created by Albin Joseph on 24/08/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SafariServices

 struct firebasDBKey {
    static let survey = "Survey"
}

class SurveyListViewController: UIViewController {
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    var surveyList: [SubTopic] = []

    @IBOutlet weak var surveyTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        fetchSurveys()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchSurveys() {
        
        if surveyList.count == 0 {
            ref?.child(firebasDBKey.survey).observe(DataEventType.value, with: { (snapshot) in
                let contents = snapshot.value as? [String : AnyObject] ?? [:]
                for content in contents {
                    let subTopic = SubTopic(title: content.key, url: content.value as! String)
                    self.surveyList.append(subTopic)
                    self.surveyTableView.reloadData()
                }
            })
        }
    }

}

extension SurveyListViewController: UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let surveyItem = surveyList[indexPath.row]
        cell.textLabel?.text = surveyItem.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let surveyItem = surveyList[indexPath.row]
        let safariView = SFSafariViewController(url: URL(string: surveyItem.url)!)
        navigationController?.present(safariView, animated: true)
    }
}
