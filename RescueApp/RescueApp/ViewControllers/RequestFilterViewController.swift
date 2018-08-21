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
    var requestType: RequestType!
    
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var locationTextfield: UITextField!
    @IBOutlet private weak var keywordsTextfield: UITextField!
    @IBOutlet private weak var timePeriods: UIButton!
    @IBOutlet private weak var timePeriodsPickerView: UIPickerView!
    @IBOutlet private weak var applyButton: UIButton!
    @IBOutlet private weak var clearAllButton: UIButton!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    
    private var datePeriods = ["only last day", "within last week", "within last month", "all"]
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    // MARK: Button Actions
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApply(_ sender: Any) {
        
        print(requests.count)
        print(requests)
        
        
        var filteredRequests = requests
        let filterModel = FilterModel()
        if let locationName = locationTextfield.text, locationName.count > 0 {
            filterModel.locationName = locationName
            filteredRequests = filterWithLocationName(locationName, requests: filteredRequests)
        } else {
            filterModel.locationName = ""
        }
        
        if let keywords = keywordsTextfield.text, keywords.count > 0 {
            filterModel.keyWord = keywords
            filteredRequests = filterWithKeywords(keywords, requests: filteredRequests)
        } else {
            filterModel.keyWord = ""
        }
        
        if let period = selectedDatePeriod {
            filterModel.timePeriod = period
            filteredRequests = filterWithDatePeriod(period, requests: filteredRequests)
        } else {
            filterModel.timePeriod = 0
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.filterModel = filterModel
        delegate?.didFinishApplyingFilters(filters: filteredRequests)
            
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSelectTimePeriod(_ sender: Any) {
        timePeriods.isSelected = !timePeriods.isSelected
        selectedDatePeriod = 1
        refreshUI()
    }
    
    @IBAction func onClearAllFilters(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.filterModel = nil
        delegate?.didFinishApplyingFilters(filters: ResultOptimizer.shared.getRequests(requestType))
        dismiss(animated: true, completion: nil)
    }
}


// MARK: Helper methods

private extension RequestFilterViewController {
    /**
     here all the UI is configured once when view is loaded
     */
    func configureUI() {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let _filterModel = appDelegate.filterModel else {
            return
        }
        locationTextfield.text = _filterModel.locationName
        keywordsTextfield.text = _filterModel.keyWord
    }
    
    func updateUI() {
        title = NSLocalizedString("Filters", comment: "")
        GradientHelper.addHorizontalGradient(RAColorSet.RAGREEN.cgColor,
                                   bottom: RAColorSet.RABLUE_GREENISH.cgColor,
                                   toView: applyButton)
        GradientHelper.addHorizontalGradient(RAColorSet.RAGREEN.cgColor,
                                             bottom: RAColorSet.RABLUE_GREENISH.cgColor,
                                             toView: clearAllButton)
        applyButton.setTitle(NSLocalizedString("Apply", comment: ""), for: .normal)
        applyButton.setTitle(NSLocalizedString("Apply", comment: ""), for: .selected)
        
        clearAllButton.setTitle(NSLocalizedString("ClearAllFilters", comment: ""), for: .normal)
        clearAllButton.setTitle(NSLocalizedString("ClearAllFilters", comment: ""), for: .selected)
        
        locationTextfield.placeholder = NSLocalizedString("LocationsSearchPlaceholder", comment: "")
        keywordsTextfield.placeholder = NSLocalizedString("KeywordsSearchPlaceholder", comment: "")
        
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
    }
    
    func refreshUI() {
        timePeriodsPickerView.isHidden = !timePeriods.isSelected
    }
    
    func filterWithLocationName(_ locationName: String, requests from: [RequestModel]) -> [RequestModel] {
        return from.filter { $0.location?.lowercased().contains(locationName.lowercased()) ?? false }
    }
    
    func filterWithKeywords(_ keywords: String, requests from: [RequestModel]) -> [RequestModel] {
        return from.filter {
            $0.supply_details?.lowercased().contains(keywords.lowercased()) ?? false ||
            $0.detailmed?.lowercased().contains(keywords.lowercased()) ?? false ||
            $0.detailfood?.lowercased().contains(keywords.lowercased()) ?? false ||
            $0.detailcloth?.lowercased().contains(keywords.lowercased()) ?? false ||
            $0.detailwater?.lowercased().contains(keywords.lowercased()) ?? false ||
            $0.detailtoilet?.lowercased().contains(keywords.lowercased()) ?? false ||
            $0.detailkit_util?.lowercased().contains(keywords.lowercased()) ?? false 
        }
    }
    
    func filterWithDatePeriod(_ period: Int, requests from: [RequestModel]) -> [RequestModel] {
        print(period)
        var minimDate: String!
        var date = Date()
        switch period {
        case 1:
            date.addTimeInterval(-TimeInterval(C.oneDayInSeconds))
            minimDate = dateString(date: date)
        case 2:
            date.addTimeInterval(-TimeInterval(C.oneWeekInSeconds))
            minimDate = dateString(date: date)
        case 3:
            date.addTimeInterval(-TimeInterval(C.oneMonthInSeconds))
            minimDate = dateString(date: date)
        default:
            return from
        }
        
        print(minimDate)
        return from.filter { $0.dateadded?.compare(minimDate) != ComparisonResult.orderedAscending }
    }
    
    func dateString(date: Date?) -> String? {
        guard let _date = date else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDatePeriod = row + 1
        timePeriods.setTitle(datePeriods[row], for: .normal)
        timePeriods.setTitle(datePeriods[row], for: .selected)
    }
}
