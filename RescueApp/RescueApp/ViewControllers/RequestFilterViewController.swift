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
}

protocol RequestFilterProtocol {
    func didFiltersSelected(filters: [FilterTypes])
}

class RequestFilterViewController: UIViewController {
    
    @IBOutlet private weak var navigationBar: UINavigationBar!
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }

    // MARK: Button Actions
    @IBAction func onCancel(_ sender: Any) {
        
    }
    
    @IBAction func onApply(_ sender: Any) {
        
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
}
