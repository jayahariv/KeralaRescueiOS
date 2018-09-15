//
/*
Colors.swift
Created on: 20/8/18

Abstract:
Color helper methods

*/

import UIKit

struct RAColorSet {
    // HOME BANNER
    static let DARK_BLUE = UIColor(red: 13/255, green: 54/255, blue: 102/255, alpha: 1.0)
    
    // HOME CELL COLORS
    static let RED = UIColor(red: 250/255, green: 88/255, blue: 117/255, alpha: 1.0)
    static let LIGHT_BLUE = UIColor(red: 0/255, green: 181/255, blue: 1, alpha: 1.0)
    static let PURPLE = UIColor(red: 180/255, green: 82/255, blue: 200/255, alpha: 1.0)
    static let GREEN = UIColor(red: 10/255, green: 203/255, blue: 168/255, alpha: 1.0)
    static let YELLOW = UIColor(red: 250/255, green: 181/255, blue: 0, alpha: 1.0)
    
    // MISC
    static let AFTER_FLOOD_HEADER_BLACK = UIColor(red: 14/255, green: 14/255, blue: 14/255, alpha: 1.0)
    static let RABLUE_GREENISH = UIColor(red: 102/255, green: 189/255, blue: 231/255, alpha: 1.0)
    static let RAGREEN = UIColor(red: 109/255, green: 195/255, blue: 132/255, alpha: 1.0)
    static let GRADIENTSTART = UIColor(red: 72/255, green: 201/255, blue: 104/255, alpha: 1.0)
    static let GRADIENTEND = UIColor(red: 69/255, green: 189/255, blue: 236/255, alpha: 1.0)
    static let TEXTFIELD_BORDER = UIColor(red: 197/255, green: 197/255, blue: 197/255, alpha: 1.0)
    static let HEADER_BACKGROUD = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 1.0)
    static let TABLE_BACKGROUND = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
    static let DARK_TEXT_COLOR = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    static let SECONDARY_TEXT_COLOR = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    static let LINK_COLOR = UIColor(red: 68/255, green: 200/255, blue: 245/255, alpha: 1.0)
    static let WARNING_RED = UIColor(red: 210/255, green: 59/255, blue: 35/255, alpha: 1.0)
    static let SAFE_GREEN = UIColor(red: 66/255, green: 147/255, blue: 44/255, alpha: 1.0)
}

final class Colors: NSObject {
    var gl: CAGradientLayer!
    
    init(_ top: CGColor, bottom: CGColor) {
        super.init()
        gl = CAGradientLayer()
        gl.colors = [ top, bottom]
        gl.locations = [ 0.0, 1.0]
    }
}

final class GradientHelper: NSObject {
    /**
     Button gradient
     
     */
    static func addHorizontalGradient(_ top: CGColor, bottom: CGColor, toView: UIView) {
        let colors = Colors(top, bottom: bottom)
        toView.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = toView.bounds
        backgroundLayer?.startPoint = CGPoint(x: 0.0, y: 0.5)
        backgroundLayer?.endPoint = CGPoint(x: 1.0, y: 0.5)
        backgroundLayer?.cornerRadius = 10
        toView.layer.insertSublayer(backgroundLayer!, at: 0)
    }
    
    /**
     View Gradient
     
     */
    static func addVerticalGradient(_ top: CGColor, bottom: CGColor, toView: UIView) {
        let colors = Colors(top, bottom: bottom)
        toView.backgroundColor = UIColor.clear
        let backgroundLayer = colors.gl
        backgroundLayer?.frame = toView.bounds
        toView.layer.insertSublayer(backgroundLayer!, at: 0)
    }
}
