//
/*
Colors.swift
Created on: 20/8/18

Abstract:
Color helper methods

*/

import UIKit

struct RAColorSet {
    static let RABLUE = UIColor(red: 73/255, green: 150/255, blue: 244/255, alpha: 1.0)
    static let RABLUE_LIGHT = UIColor(red: 103/255, green: 209/255, blue: 238/255, alpha: 1.0)
    static let RABLUE_GREENISH = UIColor(red: 102/255, green: 189/255, blue: 231/255, alpha: 1.0)
    static let RARED = UIColor(red: 232/255, green: 100/255, blue: 119/255, alpha: 1.0)
    static let RAGREEN = UIColor(red: 109/255, green: 195/255, blue: 132/255, alpha: 1.0)
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
        backgroundLayer?.cornerRadius = 22.5
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
