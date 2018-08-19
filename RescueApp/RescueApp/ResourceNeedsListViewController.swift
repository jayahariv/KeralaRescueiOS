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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: Button Actions
    
    @objc func onMap(_ sender: UIButton) {
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(1.0)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationTransition(.flipFromRight, for: (navigationController?.view)!, cache: false)
        navigationController?.popViewController(animated: false)
        UIView.commitAnimations()
    }
}

extension ResourceNeedsListViewController {
    func configureUI() {
        title = "Help Kerala"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(onMap(_:)))
    }
}

extension ResourceNeedsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ResultOptimizer.shared.filtered.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ListViewCell
        let model = Array(ResultOptimizer.shared.filtered.values)[indexPath.row]
        cell?.nameLabel.text = model.requestee
        cell?.locationLabel.text = model.location
        return cell!
    }
}

extension ResourceNeedsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? ResourseNeedsDetailViewController else {
            return
        }
        vc.selectedRescue = Array(ResultOptimizer.shared.filtered.values)[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
