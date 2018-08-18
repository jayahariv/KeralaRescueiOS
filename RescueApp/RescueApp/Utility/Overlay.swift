//
/*
 Overlay.swift
 Created on: 8/17/18
 
 Abstract:
 this class will help in showing the overlay with an acitivity indicator.
 
 */

import UIKit

final class Overlay: NSObject {
    private static let instance = Overlay()
    public static var shared: Overlay {
        return instance
    }
    private var view: UIView?
    
    public func show() {
        
        guard view == nil else {
            return
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if let windowFrame = delegate.window?.frame {
            
            DispatchQueue.main.async { [unowned self] in
                self.view = UIView(frame: windowFrame)
                
                let darkBackground = UIView(frame: windowFrame)
                darkBackground.backgroundColor = UIColor.black
                darkBackground.alpha = 0.25
                self.view!.addSubview(darkBackground)
                
                let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                self.view?.addSubview(activity)
                activity.center = self.view!.center
                activity.startAnimating()
                delegate.window?.addSubview(self.view!)
            }
        }
        
    }
    
    public func remove() {
        DispatchQueue.main.async { [unowned self] in
            for subview: UIView in self.view?.subviews ?? [] {
                subview.removeFromSuperview()
            }
            self.view?.removeFromSuperview()
            self.view = nil
        }
    }
}
