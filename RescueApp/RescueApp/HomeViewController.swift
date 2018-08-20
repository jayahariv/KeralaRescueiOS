//
//  HomeViewController.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    
    private struct C {
        static let foodSegueID = "foodRequest"
        static let waterSegueID = "waterRequest"
        static let medicineSegueID = "medicineRequest"
        static let clothesSegueID = "clothesRequest"
        static let alertMessage = "Data we provide is from keralarescue.in. We will fetch once from the webservice provided by keralarescue.in or else saved data on 19/08/2018."
        static let headingLabelText = "HomeHeading"
        static let subHeadingLabelText = "HomeSubHeading"
        static let alertTitle = "FirstAlert"
    }
    
    private var requests:  [String: RequestModel] {
        return ResultOptimizer.shared.filtered
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        getResources()
        
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
        
        if !UserDefaults.standard.bool(forKey: "firstTimeLoggedIn") {
            let alert = Alert.errorAlert(title: NSLocalizedString(C.alertTitle, comment: "localized"), message: nil)
            present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "firstTimeLoggedIn")
        }
        
    }
    
    func getResources() {
        Overlay.shared.showWithMessage("Please wait loading data...")
        ApiClient.shared.getResourceNeeds { (_) in
            Overlay.shared.remove()
        }
    }
    
    func refresh() {
        Overlay.shared.showWithMessage("Please wait loading data...")
        ApiClient.shared.getOnlineData(completion: { (_) in
            Overlay.shared.remove()
        })
    }
}

