//
/*
 PhotoPreviewViewController.swift
 Created on: 23/8/18
 
 Abstract:
  this will be the photo preview
 
 */

import UIKit
import FirebaseStorage

class PhotoPreviewViewController: UIViewController {
    
    
    // MARK: Properties
    /// PUBLIC
    var photo: Photo!
    
    ///PRIVATE
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textView: UITextView!
    private let storageRef: StorageReference =  Storage.storage().reference()
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        downloadImage()
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
        let placeholderImage = UIImage(named: "placeholder.jpg")
        imageView.image = placeholderImage
        
        textView.text = photo.story
        textView.isEditable = false
    }
    
    func downloadImage() {
        guard let url = photo.url else {
            return
        }
        
        Overlay.shared.show()
        // Create a reference to the file you want to download
        let imageRef = storageRef.child(url)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
            Overlay.shared.remove()
            if let error = error {
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = image
                }
            }
        }
    }
}
