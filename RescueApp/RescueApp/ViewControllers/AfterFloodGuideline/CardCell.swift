//
//  CardCell.swift
//  RescueApp
//
//  Created by Sudeep Surendran on 8/23/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import UIKit
import Cartography

class Card: UIView {
    init() {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 3
        self.layer.borderWidth = 0
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CardCell: UITableViewCell {
    let cardView = Card()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        
        self.addSubview(cardView)
        self.selectionStyle = .none
        
        constrain(cardView) {
            $0.top == $0.superview!.top + 5
            $0.bottom == $0.superview!.bottom - 5
            $0.left == $0.superview!.left + 10
            $0.right == $0.superview!.right - 10
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ContentTopicCell: CardCell {
    static let CellIndentifier = "ContentTopicCellIndentifier"

    let title: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = RAColorSet.SECONDARY_TEXT_COLOR
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cardView.addSubview(title)

        let margin: CGFloat = 20.0
        constrain(title) { title in
            title.left == title.superview!.left + margin
            title.top == title.superview!.top + 15
            title.bottom == title.superview!.bottom - 15
            title.right == title.superview!.right - margin
        }
    }
    
    func initialize(withTitle title: String) {
        self.title.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
