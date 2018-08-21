//
//  ListViewCell.swift
//  RescueApp
//
//  Created by Akhil MS on 17/08/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation
import UIKit

class ListViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rescueView: UIView!
    @IBOutlet weak var foodWaterView: UIView!
    @IBOutlet weak var medicineView: UIView!
    @IBOutlet weak var clothsView: UIView!
}
