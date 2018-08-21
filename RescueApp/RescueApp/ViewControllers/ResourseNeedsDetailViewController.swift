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
    
    private struct C {
        static let weCareMessageBody = "WeCareMessageBody"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Details", comment: "")
        updateUI()
    }
    
    func updateUI() {
        populateData()
        updateRequestedServiceView()
        updateRequestForSelf()
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
        dateLabel.text = dateString(date: date(from: selectedRescue?.dateadded))
    }
    
    @IBAction func callButtonAction(sender: Any) {
        guard let phoneNo = selectedRescue?.requestee_phone, let number = URL(string: "tel://\(phoneNo)") else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func weCareAction(sender: Any) {
         guard
            let phoneNo = selectedRescue?.requestee_phone,
            MFMessageComposeViewController.canSendText()
        else {
            return
        }
        let controller = MFMessageComposeViewController()
        controller.body = NSLocalizedString(C.weCareMessageBody, comment: "localized")
        controller.recipients = [phoneNo]
        controller.messageComposeDelegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    func date(from dateString: String?) -> Date? {
        guard let _date = dateString else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.date(from: _date)
    }
    
    func dateString(date: Date?) -> String? {
        guard let _date = date else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: _date)
    }
    
    func updateRequestedServiceView() {
        if let _needRescue = selectedRescue?.needrescue, _needRescue {
            rescue.isHidden = false
        } else {
            rescue.isHidden = true
        }
        if let _needcloth = selectedRescue?.needcloth, _needcloth {
            cloths.isHidden = false
        } else {
            cloths.isHidden = true
        }
        if let _needmed = selectedRescue?.needmed, _needmed {
            medicine.isHidden = false
        } else {
            medicine.isHidden = true
        }
        if let _needwater = selectedRescue?.needwater, let _needfood = selectedRescue?.needfood, (_needwater || _needfood) {
            foodWater.isHidden = false
        } else {
            foodWater.isHidden = true
        }
    }
    
    func updateRequestForSelf() {
        guard let requestForOthers = selectedRescue?.is_request_for_others else { return }
        if  requestForOthers {
            requestForSelfImage.image = #imageLiteral(resourceName: "cross")
        } else {
            requestForSelfImage.image = #imageLiteral(resourceName: "checked")
        }
    }
}

extension ResourseNeedsDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}




