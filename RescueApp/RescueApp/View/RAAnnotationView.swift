//
/*
RAAnnotationView.swift
Created on: 8/17/18

Abstract:
 this will show the custom annotation

*/

import UIKit

protocol RAAnnotationViewProtocol {
    func didCall()
}

final class RAAnnotationView: UIView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location : UILabel!
    @IBOutlet weak var resIcon: UIImageView!
    @IBOutlet weak var medIcon: UIImageView!
    @IBOutlet weak var foodIcon: UIImageView!
    
    var delegate: RAAnnotationViewProtocol?
    
    @IBAction func onTouchCall(_ sender: UIButton) {
        delegate?.didCall()
    }
}
