//
/*
PhotoGalleryViewController.swift
Created on: 23/8/18

Abstract:
 this will be the gallery view for the heros of flood

*/

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

final class PhotoGalleryViewController: UIViewController, RANavigationProtocol {
    
    // MARK:  Properties
    /// PRIVATE
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var courtesyLabel: UILabel!
    private var images = [Photo]()
    private struct C {
        static let TITLE = "Rescue Photos '18"
        static let tableViewCellID = "photoGalleryTableViewCell"
        static let IMAGE_VIEW_TAG = 1
        struct FirebaseKeys {
            static let HEROS_OF_INDIA_ROOT = "heros_of_India"
        }
        
        static let segueToPreview = "segueToPreview"
        static let OFFLINE_ALERT_MESSAGE = "Photo Gallery requires internet connection. Please check your connection and try again."
        static let COURTESY_TEXT = "Courtesy: Public photos & stories from facebook.com"
    }
    private var ref: DatabaseReference?
    private let storageRef: StorageReference =  Storage.storage().reference()
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUIFromViewDidLoad()
        showAlertIfNoConnection()
        fetchPhotoGalleryFromFirebase()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == C.segueToPreview {
            let vc = segue.destination as! PhotoPreviewViewController
            vc.photo = sender as! Photo
        }
    }
}

// MARK: Helper methods

private extension PhotoGalleryViewController {
    func configureUIFromViewDidLoad() {
        tableView.isHidden = true
        title = C.TITLE
        navigationItem.backBarButtonItem = UIBarButtonItem()
        configureNavigationBar(RAColorSet.YELLOW)
        courtesyLabel.text = C.COURTESY_TEXT
    }
    
    func showAlertIfNoConnection() {
        if !ApiClient.isConnected {
            let alert = Alert.errorAlert(title: C.OFFLINE_ALERT_MESSAGE,
                                         message: nil,
                                         cancelButton: false) { [weak self] in
                                            self?.navigationController?.popViewController(animated: true)
            }
            present(alert, animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    func fetchPhotoGalleryFromFirebase() {
        guard ApiClient.isConnected else {
            return
        }
        Overlay.shared.show()
        ref = Database.database().reference()
        ref?.child(C.FirebaseKeys.HEROS_OF_INDIA_ROOT).observe(DataEventType.value, with: { [weak self] (snapshot) in
            Overlay.shared.remove()
            let contents = snapshot.value as? [String : AnyObject] ?? [:]
            var photos = [Photo]()
            for content in contents.values {
                if let photoDictionary  = content as? [String: AnyObject] {
                    let pic = Photo(photoDictionary)
                    photos.append(pic)
                }
            }
            self?.images = photos
            self?.refreshUI()
        })
    }
    
    func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension PhotoGalleryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: C.tableViewCellID)
        cell?.selectionStyle = .none
        let photo = images[indexPath.row]
        let imageView = cell?.viewWithTag(1) as! UIImageView
        if let url = photo.url {
            let reference = storageRef.child(url)
            let placeholderImage = UIImage(named: "placeholder.jpg")
            imageView.sd_setImage(with: reference, placeholderImage: placeholderImage)
        }
        let descriptionLabel = cell?.viewWithTag(2) as! UILabel
        descriptionLabel.text = photo.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: C.segueToPreview, sender: images[indexPath.row])
    }
}
