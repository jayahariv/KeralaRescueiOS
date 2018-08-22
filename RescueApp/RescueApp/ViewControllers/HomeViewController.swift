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
    @IBOutlet weak var lastUpdatedTimeLabel: UILabel!
    
    private struct C {
        static let foodSegueID = "foodRequest"
        static let waterSegueID = "waterRequest"
        static let medicineSegueID = "medicineRequest"
        static let clothesSegueID = "clothesRequest"
        static let headingLabelText = "HomeHeading"
        static let subHeadingLabelText = "HomeSubHeading"
        static let alertTitle = "FirstAlert"
        static let LoadingDataFromServer = "LoadingDataFromServer"
    }
    
    private var requests:  [String: RequestModel] {
        return ResultOptimizer.shared.filtered
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        getResources()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        clearSavedFilters()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientHelper.addVerticalGradient(RAColorSet.RABLUE_LIGHT.cgColor,
                                           bottom: RAColorSet.RABLUE.cgColor,
                                           toView: headingContainer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var requests = [RequestModel]()
        var requestType: RequestType!
        if segue.identifier == C.foodSegueID {
            requests = ResultOptimizer.shared.forFood
            requestType = .food
        } else if segue.identifier == C.waterSegueID {
            requests = ResultOptimizer.shared.forWater
            requestType = .water
        } else if segue.identifier == C.medicineSegueID {
            requests = ResultOptimizer.shared.forMedicine
            requestType = .medicine
        } else if segue.identifier == C.clothesSegueID {
            requests = ResultOptimizer.shared.forClothes
            requestType = .clothes
        }
        
        let vc =  segue.destination as! ResourceNeedsListViewController
        vc.requests = requests
        vc.requestsType = requestType
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        refresh()
    }
}

extension HomeViewController {
    
    func configureUI() {
        // title color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
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
        
        refreshUI()
    }
    
    func clearSavedFilters() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.filterModel = nil
    }
    
    func updateUI() {
        navigationController?.navigationBar.barTintColor = RAColorSet.RABLUE_LIGHT
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func getResources() {
        Overlay.shared.showWithMessage(NSLocalizedString(C.LoadingDataFromServer, comment: ""))
        ApiClient.shared.getResourceNeeds { (_) in
            Overlay.shared.remove()
        }
    }
    
    func refresh() {
        Overlay.shared.showWithMessage(NSLocalizedString(C.LoadingDataFromServer, comment: ""))
        ApiClient.shared.getOnlineData(completion: { [weak self] (_) in
            Overlay.shared.remove()
            self?.refreshUI()
        })
    }
    
    /**
     refresh any UI when the something changes can be done inside this method
     
     */
    func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            let timestamp = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.REQUESTS_LAST_UPDATED_TIME)
            if timestamp != 0 {
                let formattedString = Utility.formattedDate(date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
                                                            format: "dd-MMMM-yyyy h:mm a")
                self?.lastUpdatedTimeLabel.text = "Requests last updated: \(formattedString)"
            }
        }
        
    }
}

