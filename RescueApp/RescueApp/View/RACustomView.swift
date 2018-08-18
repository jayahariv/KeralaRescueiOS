//
/*
RAAnnotationView.swift
Created on: 8/17/18

Abstract:
 this will show the custom annotation

*/

import UIKit

protocol RACustomViewProtocol {
    func didCall()
}

final class RACustomView: UIView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location : UILabel!
    @IBOutlet weak var resIcon: UIImageView!
    @IBOutlet weak var medIcon: UIImageView!
    @IBOutlet weak var foodIcon: UIImageView!
    
    var delegate: RACustomViewProtocol?
    
    @IBAction func onTouchCall(_ sender: UIButton) {
        delegate?.didCall()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
