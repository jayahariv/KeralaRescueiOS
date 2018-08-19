//
//  HomeViewController.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var provideResource: UIButton!
    
    private struct C {
        static let foodSegueID = "foodRequest"
        static let waterSegueID = "waterRequest"
        static let medicineSegueID = "medicineRequest"
        static let clothesSegueID = "clothesRequest"
        static let alertMessage = "Data we provide is getting from keralarescue.in. We will fetch through the service or if not saved data on 19/08/2018."
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
        if segue.identifier == C.foodSegueID {
            requests = ResultOptimizer.shared.forFood
        } else if segue.identifier == C.waterSegueID {
            requests = ResultOptimizer.shared.forWater
        } else if segue.identifier == C.medicineSegueID {
            requests = ResultOptimizer.shared.forMedicine
        } else if segue.identifier == C.clothesSegueID {
            requests = ResultOptimizer.shared.forClothes
        }
        
        let vc =  segue.destination as! ResourceNeedsMapViewController
        vc.requests = requests
    }
}

extension HomeViewController {
    
    func configureUI() {
        // TODO: Set any UIs
    }
    
    func getResources() {
        Overlay.shared.showWithMessage("Please wait loading data...")
        ApiClient.shared.getResourceNeeds { (_) in
            Overlay.shared.remove()
        }
    }
}

