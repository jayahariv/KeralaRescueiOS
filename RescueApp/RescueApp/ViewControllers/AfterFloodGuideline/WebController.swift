//
//  WebController.swift
//  RescueApp
//
//  Created by Sudeep Surendan on 8/24/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation
import UIKit
import Cartography

class WebController: UIViewController {
    var webview: UIWebView
    var pageHtml: String?
    var url: URL?

    init(withPageHtml html: String) {
        pageHtml = html
        webview = UIWebView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(withUrl url: String) {
        self.url = URL(string: url)
        webview = UIWebView(frame: .zero)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(webview)
        
        constrain(webview) { webview in
            webview.top == webview.superview!.top
            webview.left == webview.superview!.left
            webview.right == webview.superview!.right
            webview.bottom == webview.superview!.bottom
        }
        
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("Details", comment: "")
        
        if let html = pageHtml {
            webview.loadHTMLString(html, baseURL: nil)
        } else if let url = self.url {
            webview.loadRequest(URLRequest(url: url))
        }
    }
}
