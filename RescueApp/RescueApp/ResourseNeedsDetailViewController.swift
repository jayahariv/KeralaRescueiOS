//
//  ResourseNeedsDetailViewController.swift
//  RescueApp
//
//  Created by Akhil MS on 18/08/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ResourseNeedsDetailViewController: UIViewController {
    @IBOutlet weak var nameAndDist: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rescue: UIView!
    @IBOutlet weak var foodWater: UIView!
    @IBOutlet weak var medicine: UIView!
    @IBOutlet weak var cloths: UIView!
    @IBOutlet weak var requestForSelfImage: UIImageView!
    var selectedRescue: RequestModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        populateData()
    }
    
    func populateData() {
        nameAndDist.text = "\(selectedRescue?.requestee ?? "")" + "," + " \(selectedRescue?.district ?? "")"
        location.text = selectedRescue?.location
        var detailsString = ""
        if let phone = selectedRescue?.requestee_phone {
            detailsString = phone
            detailsString = detailsString + "/n"
        }
        if let rescueDetail = selectedRescue?.detailrescue {
            detailsString = detailsString + rescueDetail
            detailsString = detailsString + "/n"
        }
        if let medDetails = selectedRescue?.detailmed {
            detailsString = detailsString + medDetails
            detailsString = detailsString + "/n"
        }
        if let foodDetail = selectedRescue?.detailfood {
            detailsString = detailsString + foodDetail
            detailsString = detailsString + "/n"
        }
        if let waterDetail = selectedRescue?.detailwater {
            detailsString = detailsString + waterDetail
            detailsString = detailsString + "/n"
        }
        dateLabel.text = selectedRescue?.dateadded
    }
    
    @IBAction func callButtonAction(sender: Any) {
    
    }
    
    func dateString(date: Date?) -> String? {
        guard let _date = date else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: _date)
    }
}
