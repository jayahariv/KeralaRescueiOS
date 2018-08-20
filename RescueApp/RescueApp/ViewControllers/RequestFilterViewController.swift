//
/*
RequestFilterViewController.swift
Created on: 19/8/18

Abstract:
 Requests filters are controlled inside this class.

*/

import UIKit

enum FilterTypes {
    case location
    case keywords
    case datePeriods
}

protocol RequestFilterProtocol {
    func didFinishApplyingFilters(filters: [RequestModel])
}

class RequestFilterViewController: UIViewController {
    
    var requests = [RequestModel]()
    var delegate: RequestFilterProtocol?
    
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var locationTextfield: UITextField!
    @IBOutlet private weak var keywordsTextfield: UITextField!
    @IBOutlet private weak var timePeriods: UIButton!
    @IBOutlet private weak var timePeriodsPickerView: UIPickerView!
    
    private var datePeriods = ["yesterday", "within last week", "within last month" ]
    private var selectedDatePeriod: Int? = 0
    
    private struct C {
        static let oneDayInSeconds = 24 * 60 * 60
        static let oneWeekInSeconds = 7 * 24 * 60 * 60
        static let oneMonthInSeconds = 31 * 24 * 60 * 60
    }
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }

    // MARK: Button Actions
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApply(_ sender: Any) {
        
        print(requests.count)
        var filteredRequests = requests
        if let locationName = locationTextfield.text, locationName.count > 0 {
            filteredRequests = filterWithLocationName(locationName, requests: filteredRequests)
        }
        
        if let keywords = keywordsTextfield.text, keywords.count > 0 {
            filteredRequests = filterWithKeywords(keywords, requests: filteredRequests)
        }
        
        if let period = selectedDatePeriod {
            filteredRequests = filterWithDatePeriod(period, requests: filteredRequests)
        }
        
        delegate?.didFinishApplyingFilters(filters: filteredRequests)
            
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSelectTimePeriod(_ sender: Any) {
        timePeriods.isSelected = !timePeriods.isSelected
        
        refreshUI()
    }
}


// MARK: Helper methods

private extension RequestFilterViewController {
    /**
     here all the UI is configured once when view is loaded
     */
    func configureUI() {
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func refreshUI() {
        timePeriodsPickerView.isHidden = !timePeriods.isSelected
    }
    
    func filterWithLocationName(_ locationName: String, requests from: [RequestModel]) -> [RequestModel] {
        return from.filter { $0.location?.lowercased().contains(locationName.lowercased()) ?? false }
    }
    
    func filterWithKeywords(_ keywords: String, requests from: [RequestModel]) -> [RequestModel] {
        return from.filter { $0.supply_details?.lowercased().contains(keywords.lowercased()) ?? false }
    }
    
    func filterWithDatePeriod(_ period: Int, requests from: [RequestModel]) -> [RequestModel] {
        var minimDate: String!
        switch period {
        case 1:
            minimDate = dateString(date: Date().addingTimeInterval(TimeInterval(C.oneDayInSeconds)))
        case 2:
            minimDate = dateString(date: Date().addingTimeInterval(TimeInterval(C.oneWeekInSeconds)))
        case 3:
            minimDate = dateString(date: Date().addingTimeInterval(TimeInterval(C.oneMonthInSeconds)))
        default:
            return from
        }
        
        return from.filter {$0.dateadded?.compare(minimDate) == ComparisonResult.orderedAscending}
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

extension RequestFilterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datePeriods.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datePeriods[row]
    }
}
