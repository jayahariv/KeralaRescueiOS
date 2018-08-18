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
        
    }
    
    // MARK: Button Actions
    
    @IBAction func onMap(_ sender: UIButton) {
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(1.0)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationTransition(.flipFromRight, for: (navigationController?.view)!, cache: false)
        navigationController?.popViewController(animated: false)
        UIView.commitAnimations()
    }
}

extension ResourceNeedsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "test"
        return cell!
    }
}
