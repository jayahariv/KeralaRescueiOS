//
/*
PhotoGalleryViewController.swift
Created on: 23/8/18

Abstract:
 this will be the gallery view for the heros of flood

*/

import UIKit
import FirebaseDatabase

final class PhotoGalleryViewController: UIViewController, RANavigationProtocol {
    
    // MARK:  Properties
    /// PRIVATE
    @IBOutlet private weak var collectionView: UICollectionView!
    private var images = [Photo]()
    private struct C {
        static let collectionCellID = "collectionCell"
        static let IMAGE_VIEW_TAG = 1
        struct FirebaseKeys {
            static let HEROS_OF_INDIA_ROOT = "heros_of_India"
        }
        
        static let segueToPreview = "segueToPreview"
    }
    private var ref: DatabaseReference?
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadFromFirebase()
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
    /**
     configure all ui components once when view is loaded
     
     */
    func configureUI() {
        configureNavigationBar(RAColorSet.YELLOW)
    }
    
    /**
     load the data from firebase to get all the images
     
     */
    func loadFromFirebase() {
        ref = Database.database().reference()
        ref?.child(C.FirebaseKeys.HEROS_OF_INDIA_ROOT).observe(DataEventType.value, with: { [weak self] (snapshot) in
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
    
    /**
     refresh the UI
     
     */
    func refreshUI() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

// MARK: PhotoGalleryViewController -> UICollectionViewDataSource

extension PhotoGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: C.collectionCellID,
                                                      for: indexPath) as! PhotoCollectionViewCell
        let photo = images[indexPath.row]
        if let url = photo.url {
            cell.setBackground(url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: C.segueToPreview, sender: images[indexPath.row])
    }
}
