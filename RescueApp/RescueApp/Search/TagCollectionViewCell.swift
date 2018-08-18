//
//  TagCollectionViewCell.swift
//  RescueSearchView
//
//  Created by Nitin George on 8/17/18.
//  Copyright © 2018 Nitin George. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    
    private let normalColor = UIColor(red: 0.1686, green: 0.4313, blue: 0.7647, alpha: 1.0)
    private let selectedColor = UIColor(red: 0.41568, green: 0.6627, blue: 0.9764, alpha: 1.0)
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.backgroundColor = selectedColor
            }
            else {
                self.backgroundColor = normalColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = normalColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
}
