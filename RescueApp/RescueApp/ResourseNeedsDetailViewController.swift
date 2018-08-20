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
import MessageUI

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
            detailsString = detailsString + "\n"
        }
        if let rescueDetail = selectedRescue?.detailrescue, !rescueDetail.isEmpty {
            detailsString = detailsString + rescueDetail
            detailsString = detailsString + "\n"
        }
        if let medDetails = selectedRescue?.detailmed, !medDetails.isEmpty {
            detailsString = detailsString + medDetails
            detailsString = detailsString + "\n"
        }
        if let foodDetail = selectedRescue?.detailfood, !foodDetail.isEmpty {
            detailsString = detailsString + foodDetail
            detailsString = detailsString + "\n"
        }
        if let waterDetail = selectedRescue?.detailwater, !waterDetail.isEmpty {
            detailsString = detailsString + waterDetail
            detailsString = detailsString + "\n"
        }
        details.text = detailsString
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
    
    /**
     on click We Care button, we will send an SMS, mentioning we all care for them.  giving a hope!!
     
     - todo: send only one message to one person.
     - notice: receipent number need to mention and connect to IB
     */
    @IBAction func onWeCare(_ sender: Any) {
        // todo send this only once to a single person
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "We all care for you. Together we will overcome!"
            controller.recipients = ["123456789"]
            controller.messageComposeDelegate = self
            present(controller, animated: true, completion: nil)
        }
    }
}

extension ResourseNeedsDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
    
    
}