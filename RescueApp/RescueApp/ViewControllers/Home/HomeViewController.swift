//
//  HomeViewController.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var headingContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private struct C {
        struct SEGUE {
            static let SURVEY = "segueToSurvey"
            static let CONTACTS = "segueToContacts"
            static let PHOTO_GALLERY = "segueToPhotoGallery"
            static let HOW_TO_PREPARE = "segueToHowToPrepare"
        }
        static let foodSegueID = "foodRequest"
        static let waterSegueID = "waterRequest"
        static let medicineSegueID = "medicineRequest"
        static let clothesSegueID = "clothesRequest"
        static let headingLabelText = "HomeHeading"
        static let subHeadingLabelText = "HomeSubHeading"
        static let alertTitle = "FirstAlert"
        static let LoadingDataFromServer = "LoadingDataFromServer"
        struct HomeCellKeys {
            static let title = "title"
            static let color = "color"
        }
    }
    private var requests:  [String: RequestModel] {
        return RAStore.shared.filtered
    }
    private var homeCells: [[String: AnyObject]] {
        return [
            [C.HomeCellKeys.title: "How to Prepare", C.HomeCellKeys.color: RAColorSet.RED],
            [C.HomeCellKeys.title: "Tips after a Flood", C.HomeCellKeys.color: RAColorSet.LIGHT_BLUE],
            [C.HomeCellKeys.title: "Emergency Contacts", C.HomeCellKeys.color: RAColorSet.PURPLE],
            [C.HomeCellKeys.title: "Usahidi Survey app", C.HomeCellKeys.color: RAColorSet.GREEN],
            [C.HomeCellKeys.title: "2018 Rescue Photos", C.HomeCellKeys.color: RAColorSet.YELLOW]
        ] as [[String: AnyObject]]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        clearSavedFilters()
    }
    
    @IBAction func onGuideTap(_ sender: Any) {
        
       /* let viewController:SurveyListViewController = UIStoryboard(name: "Survey", bundle: nil).instantiateViewController(withIdentifier: "SurveyListViewController") as! SurveyListViewController
        self.navigationController?.pushViewController(viewController, animated: true)*/
    }
}

extension HomeViewController {
    
    func configureUI() {
        // title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = RAColorSet.DARK_BLUE
        }
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        tableView.tableHeaderView = UIView(frame: frame)
        
        // back button
        let backItem = UIBarButtonItem()
        backItem.title = "Home"
        navigationItem.backBarButtonItem = backItem
        
        // set texts
        headingLabel.text = NSLocalizedString(C.headingLabelText, comment: "localised")
        subHeadingLabel.text = NSLocalizedString(C.subHeadingLabelText, comment: "localised")
        
        if !UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.FIRST_TIME_LOGIN) {
            let alert = Alert.errorAlert(title: NSLocalizedString(C.alertTitle, comment: "localized"), message: nil)
            present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "firstTimeLoggedIn")
        }
        
        titleLabel.text = NSLocalizedString("AppTitle", comment: "localised")
    }
    
    func clearSavedFilters() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.filterModel = nil
    }
    
    func updateUI() {
        navigationController?.navigationBar.barTintColor = RAColorSet.DARK_BLUE
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return homeCells.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell")
        let homeCellInfo = homeCells[indexPath.section]
        cell?.textLabel?.text = homeCellInfo[C.HomeCellKeys.title] as? String
        cell?.backgroundColor = homeCellInfo[C.HomeCellKeys.color] as? UIColor
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var identifier: String!
        switch indexPath.section {
        case 0:
            identifier = C.SEGUE.HOW_TO_PREPARE
        case 1:
            let guideViewController = GuidelineContentController()
            self.navigationController?.pushViewController(guideViewController, animated: true)
            return
        case 2:
            identifier = C.SEGUE.CONTACTS
        case 3:
            identifier = C.SEGUE.SURVEY
        case 4:
            identifier = C.SEGUE.PHOTO_GALLERY
        default:
            abort()
        }
        performSegue(withIdentifier: identifier, sender: nil)
    }
}
