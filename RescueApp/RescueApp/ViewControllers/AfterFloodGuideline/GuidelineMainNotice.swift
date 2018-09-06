//
//  GuidelineMainNotice.swift
//  RescueApp
//
//  Created by Sudeep Surendran on 8/22/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit
import Cartography

class GuidelineMainNotice: UIView {
    let title: UILabel = {
        let label = UILabel(frame:CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        return label
    }()
    
    let subtitle: UILabel = {
        let label = UILabel(frame:CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        return label
    }()
    
    let noteIcon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "cross"))
        imageView.isUserInteractionEnabled = false
        constrain(imageView) {
            $0.width == 40
            $0.height == 40
        }
        return imageView
    }()
    
    init(frame: CGRect, titleText: String, subtitleText: String?) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        title.text = titleText
        subtitle.text = subtitleText
        
        self.addSubview(title)
        self.addSubview(noteIcon)
        
        let margin: CGFloat = 20.0
        constrain(title, noteIcon) { title, noteIcon in
            noteIcon.left == noteIcon.superview!.left + 20
            noteIcon.centerY == noteIcon.superview!.centerY

            title.left == noteIcon.right + 10
            title.right == title.superview!.right - margin
            title.top == title.superview!.top + margin
        }
        
        if subtitleText != nil {
            self.addSubview(subtitle)
            constrain(title, subtitle) { title, subtitle in
                subtitle.left == title.left
                subtitle.top == title.bottom + 10
                subtitle.width == subtitle.superview!.width - (2 * margin)
                subtitle.bottom == subtitle.superview!.bottom - margin
            }
        } else {
            constrain(title) {
                $0.bottom == $0.superview!.bottom - margin
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
