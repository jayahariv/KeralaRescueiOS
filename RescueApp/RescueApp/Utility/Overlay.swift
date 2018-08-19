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
        showWithMessage()
    }
    
    public func showWithMessage(_ message: String? = nil) {
        
        guard view == nil else {
            return
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if let windowFrame = delegate.window?.frame {
            
            DispatchQueue.main.async { [unowned self] in
                self.view = UIView(frame: windowFrame)
                
                let darkBackground = UIView(frame: windowFrame)
                darkBackground.backgroundColor = UIColor.black
                darkBackground.alpha = 0.85
                self.view!.addSubview(darkBackground)
                
                
                let center = self.view!.center
                let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
                self.view?.addSubview(activity)
                activity.center = center
                activity.startAnimating()
                
                if message != nil {
                    
                    let padding: CGFloat = 20
                    var frame = activity.frame
                    frame.origin.y += (frame.size.height + padding)
                    frame.size.width = 400
                    let label = UILabel(frame: frame)
                    label.center = center
                    label.center.y += activity.frame.size.height + padding
                    label.text = message
                    label.textAlignment = .center
                    label.textColor = UIColor.yellow
                    self.view?.addSubview(label)
                }
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
