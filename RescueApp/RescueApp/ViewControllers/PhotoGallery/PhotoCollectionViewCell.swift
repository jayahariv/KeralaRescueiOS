//
/*
PhotoCollectionViewCell.swift
Created on: 23/8/18

Abstract:
 cell which will used to display the images

*/

import UIKit
import Firebase
import FirebaseUI

final class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backgroundImage: UIImageView!
    
    private let storageRef: StorageReference =  Storage.storage().reference()
    
    func setBackground(_ path: String) {
        let reference = storageRef.child(path)
        let placeholderImage = UIImage(named: "placeholder.jpg")
        backgroundImage.sd_setImage(with: reference, placeholderImage: placeholderImage)
    }
}
