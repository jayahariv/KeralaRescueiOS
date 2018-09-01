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
struct Topic {
    var title: String
    var url: String?
}

class SurveyListViewController: UIViewController, RANavigationProtocol {
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    var surveyList: [Topic] = []

    @IBOutlet weak var surveyTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        fetchSurveys()
        
        configureNavigationBar(RAColorSet.GREEN)
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
                    let topic = Topic(title: content.key, url: content.value as? String)
                    self.surveyList.append(topic)
                    self.surveyTableView.reloadData()
                }
            })
        }
    }
    
    func openApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
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
        let appid = surveyItem.url!
        if indexPath.row == 1{
            openApp(appId:appid ) { (true) in
            }
        }else{
            let safariView = SFSafariViewController(url: URL(string: surveyItem.url!)!)
            navigationController?.present(safariView, animated: true)
        }
    }
}
