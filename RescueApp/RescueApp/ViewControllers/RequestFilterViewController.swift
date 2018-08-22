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
    @IBOutlet private weak var applyButton: UIButton!
    @IBOutlet private weak var clearAllButton: UIButton!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var districtSelector: UIButton!
    
    private struct C {
        static let segueToDistrictList = "segueToDistrict"
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GradientHelper.addHorizontalGradient(RAColorSet.RAGREEN.cgColor,
                                             bottom: RAColorSet.RABLUE_GREENISH.cgColor,
                                             toView: applyButton)
        GradientHelper.addHorizontalGradient(RAColorSet.RAGREEN.cgColor,
                                             bottom: RAColorSet.RABLUE_GREENISH.cgColor,
                                             toView: clearAllButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.segueToDistrictList {
            let vc = segue.destination as! DistrictListViewController
            vc.delegate = self
        }
    }

    // MARK: Button Actions
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApply(_ sender: Any) {
        
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.filterModel = filterModel
        delegate?.didFinishApplyingFilters(filters: filteredRequests)
            
        dismiss(animated: true, completion: nil)
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
    
    /**
     this method will be called whenever view appears. so any UI refreshing logic can be added inside this method
     
     */
    func updateUI() {
        title = NSLocalizedString("Filters", comment: "")
        
        applyButton.setTitle(NSLocalizedString("Apply", comment: ""), for: .normal)
        applyButton.setTitle(NSLocalizedString("Apply", comment: ""), for: .selected)
        
        clearAllButton.setTitle(NSLocalizedString("ClearAllFilters", comment: ""), for: .normal)
        clearAllButton.setTitle(NSLocalizedString("ClearAllFilters", comment: ""), for: .selected)
        
        locationTextfield.placeholder = NSLocalizedString("LocationsSearchPlaceholder", comment: "")
        keywordsTextfield.placeholder = NSLocalizedString("KeywordsSearchPlaceholder", comment: "")
        
        cancelButton.title = NSLocalizedString("Cancel", comment: "")
    }
    
    /**
     filters the requests given with the locationname
     
     - parameters:
         - locationName: location name string
         - requests: list of request model objects.
     - returns: filtered list of requests.
     */
    func filterWithLocationName(_ locationName: String, requests from: [RequestModel]) -> [RequestModel] {
        return from.filter { $0.location?.lowercased().contains(locationName.lowercased()) ?? false }
    }
    
    /**
     filter using the keywords.
     
     - parameters:
         - keywords: keyword string to filter, like rice, bread.
         - requests: requests to be filtered.
     - returns: result of filter
     */
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
}


// MARK: RequestFilterViewController -> UITextFieldDelegate

extension RequestFilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: RequestFilterViewController -> DistrictListProtocol

extension RequestFilterViewController: DistrictListProtocol {
    func didSelectDistricts(_ districts: [District]) {
        
        // TODO: Filter the result
    }
}
