//
/*
RAAddressTypeahead.swift
Created on: 7/5/18

Abstract:
 - user can type in any string, which will show the matching addresses in a tableview
 - opt for the typeaheadDelegate, which will give the selected localSearchCompletion object
 
*/

import UIKit
import MapKit

/**
 delegate to receive the selected address
 */
@objc protocol RAAddressTypeaheadProtocol {
    func didSelectAddress(placemark: MKPlacemark)
}

final class RAAddressTypeahead: UITextField {
    
    // MARK: Properties
    
    /// set this to receive the selected address
    @IBOutlet var typeaheadDelegate: RAAddressTypeaheadProtocol?
    
    /// set this to show the results tableview on top of the textfield.
    @IBInspectable public var displayTop: Bool = false
    
    public var title: String? {
        set(value) {
            text = value
        }
        
        get {
            return text
        }
    }
    
    // MARK: Private properties
    private var searchCompleter = MKLocalSearchCompleter()
    private var resultsTable: UITableView!
    private var results = [MKLocalSearchCompletion]()
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        placeholder = "Please search for an address"
        resultsTable = UITableView(coder: aDecoder)
        searchCompleter.delegate = self
        addResultsTable()
    }
    
    override func layoutSubviews() {
        resultsTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.centerX,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: self,
                           attribute: NSLayoutAttribute.centerX,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.width,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute,
                           multiplier: 1,
                           constant: frame.size.width).isActive = true
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.height,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: nil,
                           attribute: NSLayoutAttribute.notAnAttribute,
                           multiplier: 1,
                           constant: 176).isActive = true
        
        if displayTop {
            addConstraintToShowResultsTableInTop()
        } else {
            addConstraintToShowResultsTableInBottom()
        }
    }
    
    /**
     captures the touches in the tableview which is overflown from textfield
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return super.hitTest(point, with: event)
    }
}

private extension RAAddressTypeahead {
    // MARK: Helper methods
    
    /**
     adds the tableview as a subview to the textfield
     */
    func addResultsTable() {
        addSubview(resultsTable)
        resultsTable.dataSource = self
        resultsTable.delegate = self
        resultsTable.isHidden = true
    }
    
    /**
     adds the constraints to show the results table below the textfield.
     */
    func addConstraintToShowResultsTableInBottom() {
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.top,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: self,
                           attribute: NSLayoutAttribute.bottom,
                           multiplier: 1,
                           constant: 12).isActive = true
    }
    
    /**
     adds the constraints to show the results table above the textfield.
     */
    func addConstraintToShowResultsTableInTop() {
        NSLayoutConstraint(item: resultsTable,
                           attribute: NSLayoutAttribute.bottom,
                           relatedBy: NSLayoutRelation.equal,
                           toItem: self,
                           attribute: NSLayoutAttribute.top,
                           multiplier: 1,
                           constant: -12).isActive = true
    }
}

// MARK: CIAddressTypeahead -> UITextFieldDelegate

extension RAAddressTypeahead: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        // only search after 3rd character
        guard let previousText = textField.text, previousText.count > 3 else {
            resultsTable.isHidden = true
            return true
        }
        
        let newString = previousText.replacingCharacters(in: Range(range, in: previousText)!, with: string)
        searchCompleter.queryFragment = newString
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return true
    }
}

// MARK: CIAddressTypeahead -> MKLocalSearchCompleterDelegate

extension RAAddressTypeahead: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        resultsTable.isHidden = results.count == 0
        resultsTable.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

// MARK: CIAddressTypeahead -> UITableViewDataSource, UITableViewDelegate

extension RAAddressTypeahead: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        let result = results[indexPath.row]
        cell?.textLabel?.text = result.title
        cell?.detailTextLabel?.text = result.subtitle
        return cell!
    }
    
    /**
     on select, calls the protocol method (`didSelectAddress`) with placemark of the selected address
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        text = results[indexPath.row].title
        let completion = results[indexPath.row]
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { [unowned self] (response, error) in
            let placemark = response?.mapItems[0].placemark
            if let placemark = placemark {
                self.typeaheadDelegate?.didSelectAddress(placemark: placemark)
                tableView.isHidden = true
            }
        }
    }
}
