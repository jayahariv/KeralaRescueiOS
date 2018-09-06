//
/*
ResourceNeedsListViewController.swift
Created on: 8/17/18

Abstract:
Resources as a list

*/

import UIKit

class ResourceNeedsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var requests = [RequestModel]()
    var requestsType: RequestType!
    
    private struct C {
        static let filterStoryBoardID = "RequestFilterViewController"
        static let segueToFilter = "segueToFilter"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    // MARK: Button Actions
    // UNUSED METHOD FOR NOW
    @objc func onMap(_ sender: UIButton) {
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(1.0)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationTransition(.flipFromRight, for: (navigationController?.view)!, cache: false)
        navigationController?.popViewController(animated: false)
        UIView.commitAnimations()
    }
    
    @objc func onFilter(_ sender: Any) {
        performSegue(withIdentifier: C.segueToFilter, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.segueToFilter {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! RequestFilterViewController
            vc.requests = RAStore.shared.getRequests(requestsType)
            vc.delegate = self
            vc.requestType = requestsType
        }
    }
    
    @objc func onBack(_ sender: Any) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 73/255, green: 150/255, blue: 244/255, alpha: 1.0)
        navigationController?.popViewController(animated: true)
    }
}

extension ResourceNeedsListViewController {
    func configureUI() {
        title = NSLocalizedString(requestsType.rawValue, comment: "")
        //UIBarButtonItem(title: "Filter", )
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(onFilter(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Home", comment: ""),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(onBack(_:)))
    }
    
    func updateUI() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 232/255, green: 100/255, blue: 119/255, alpha: 1.0)
    }
}

extension ResourceNeedsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ListViewCell
        let model = requests[indexPath.row]
        cell?.nameLabel.text = model.requestee
        cell?.locationLabel.text = model.location
        updateRequestedServiceView(for: cell!, with: model)
        return cell!
    }
    
    func updateRequestedServiceView(for cell: ListViewCell, with model: RequestModel?) {
        if let _needRescue = model?.needrescue, _needRescue {
            cell.rescueView.isHidden = false
        } else {
            cell.rescueView.isHidden = true
        }
        if let _needmed = model?.needmed, _needmed {
            cell.medicineView.isHidden = false
        } else {
            cell.medicineView.isHidden = true
        }
        if let _needwater = model?.needwater, let _needfood = model?.needfood, (_needwater || _needfood) {
            cell.foodWaterView.isHidden = false
        } else {
            cell.foodWaterView.isHidden = true
        }
        if let _needcloth = model?.needcloth, _needcloth {
            cell.clothsView.isHidden = false
        } else {
            cell.clothsView.isHidden = true
        }
    }
}

extension ResourceNeedsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? ResourseNeedsDetailViewController else {
            return
        }
        vc.selectedRescue = requests[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ResourceNeedsListViewController: RequestFilterProtocol {
    func didFinishApplyingFilters(filters: [RequestModel]) {
        requests = filters
        tableView.reloadData()
    }
}
