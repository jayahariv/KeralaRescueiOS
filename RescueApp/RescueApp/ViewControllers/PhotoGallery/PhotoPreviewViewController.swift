//
/*
 PhotoPreviewViewController.swift
 Created on: 23/8/18
 
 Abstract:
  this will be the photo preview
 
 */

import UIKit
import FirebaseStorage
import FirebaseDatabase

class PhotoPreviewViewController: UIViewController {
    
    
    // MARK: Properties
    /// PUBLIC
    var photo: Photo!
    
    ///PRIVATE
    @IBOutlet private weak var tableView: UITableView!
    private var ref: DatabaseReference?
    private var image: UIImage? = UIImage(named: "placeholder.jpg")
    private let storageRef: StorageReference =  Storage.storage().reference()
    private var comments = [[String: AnyObject]]()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        downloadImage()
        
        loadComments()
    }
    
    // MARK: Button actions
    
    @objc func onTap(_ recogniser: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Helper methods

private extension PhotoPreviewViewController {
    /**
     do all UI actions necessary during loading the view
     */
    func configureUI() {
        // all configs
    }
    
    func downloadImage() {
        guard let url = photo.url else {
            return
        }
        
        Overlay.shared.show()
        // Create a reference to the file you want to download
        let imageRef = storageRef.child(url)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { [weak self] (data, error) in
            Overlay.shared.remove()
            if let error = error {
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                let tempImage = UIImage(data: data!)
                self?.image = tempImage
                self?.refreshTableView()
            }
        }
    }
    
    func loadComments() {
        guard let photoID = photo.id else {
            return
        }
        ref = Database.database().reference()
        ref?.child("heros_of_India_comments/\(photoID)").observe(DataEventType.value, with: { [weak self] (snapshot) in
            let contents = snapshot.value as? [String : AnyObject] ?? [:]
            if let tempComments = Array(contents.values) as? [[String: AnyObject]] {
                self?.comments = tempComments
                self?.refreshTableView()
            }
        })
    }
    
    func refreshTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension PhotoPreviewViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.image = image
            let description = cell.viewWithTag(2) as! UILabel
            description.text = photo.story
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "commentCell")
            let commentTextField = cell.viewWithTag(1) as! UILabel
            let authorTextField = cell.viewWithTag(2) as! UILabel
            let timestampTextField = cell.viewWithTag(3) as! UILabel
            
            let comment = comments[indexPath.row]
            commentTextField.text = comment["comment"] as? String
            authorTextField.text = comment["author"] as? String
            timestampTextField.text = String(comment["timestamp"] as! Int)
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch indexPath.section {
//        case 0:
//            return 300
//        default:
//            return 100
//        }
//    }
    
}
