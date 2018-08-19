//
//  ResourseNeedsDetailViewController.swift
//  RescueApp
//
//  Created by Akhil MS on 18/08/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation
import UIKit

class ResourseNeedsDetailViewController: UIViewController {
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var requestee: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var coordinates: UILabel!
    @IBOutlet weak var rescueDetails: UILabel!
    @IBOutlet weak var detailsForWater: UILabel!
    @IBOutlet weak var detailsForFood: UILabel!
    @IBOutlet weak var detailsForMedicine: UILabel!
    @IBOutlet weak var utilityKitDetails: UILabel!
    @IBOutlet weak var otherNeeds: UILabel!
    
    var selectedRescue: RequestModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        populateData()
    }
    
    func populateData() {
        districtLabel.text = selectedRescue?.district
        location.text = selectedRescue?.location
        requestee.text = selectedRescue?.requestee
        phone.text = selectedRescue?.requestee_phone
        coordinates.text = selectedRescue?.latlng
        rescueDetails.text = selectedRescue?.detailrescue
        detailsForWater.text = selectedRescue?.detailwater
        detailsForFood.text = selectedRescue?.detailfood
        detailsForMedicine.text = selectedRescue?.detailmed
        utilityKitDetails.text = selectedRescue?.detailkit_util
        otherNeeds.text = selectedRescue?.needothers
    }
}
