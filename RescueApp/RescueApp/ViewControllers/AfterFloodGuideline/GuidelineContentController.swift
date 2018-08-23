//
//  GuidelineContentController.swift
//  RescueApp
//
//  Created by Sudeep Surendran on 8/22/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import FirebaseDatabase

class MenuRowItem {
    var title: String = ""
    var subTopic: [String] = []
    var isOpen: Bool = false
    
    init(withTitle title: String) {
        self.title = title
    }
}

class GuidelineContentController: UIViewController {
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    private struct Constants {
        static let title = "Guidelines"
        static let LoadingDataFromServer = "LoadingDataFromServer"
        static let CellIndentifier = "ContentCellIndentifier"
        static let CellContenrHeaderHeight: CGFloat = 60.0
        static let CellContentHeight: CGFloat = 60.0
    }
    
    private struct DBKeys {
        static let Contents = "Contents"
        static let MainNote = "MainNote"
    }
    
    private var tableView: UITableView!
    private var mainNote: String? {
        didSet {
            loadContents()
        }
    }
    private var menuRows = [MenuRowItem]() {
        didSet {
            loadContents()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.allowsSelection = true
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIndentifier)

        view.addSubview(tableView)
        
        constrain(tableView) { tableView in
            tableView.top == tableView.superview!.top
            tableView.left == tableView.superview!.left
            tableView.right == tableView.superview!.right
            tableView.bottom == tableView.superview!.bottom
        }
        
        self.view = view
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString(Constants.title, comment: "")
        
        tableView.isHidden = true
        Overlay.shared.showWithMessage(NSLocalizedString(Constants.LoadingDataFromServer, comment: ""))

        // set the firebase reference
        ref = Database.database().reference()
        fetchData()
    }
    
    private func loadContents() {
        Overlay.shared.remove()
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func fetchData() {
        ref?.child(DBKeys.Contents).observe(DataEventType.value, with: { (snapshot) in
            let contents = snapshot.value as? [String : AnyObject] ?? [:]
            for content in contents {
                let menuRow = MenuRowItem(withTitle: content.key)
                self.menuRows.append(menuRow)
            }
        })
        ref?.child(DBKeys.MainNote).observe(DataEventType.value, with: { (snapshot) in
            if let note = snapshot.value as? String, note.count > 0 {
                self.mainNote = note
                let menuRow = MenuRowItem(withTitle: note)
                self.menuRows.insert(menuRow, at: 0)
            }
        })
    }
}



extension GuidelineContentController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuRows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.CellContenrHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let menuRow = self.menuRows[section]
        return menuRow.isOpen ? menuRow.subTopic.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Constants.CellIndentifier)
        let subtitle = self.menuRows[indexPath.section].subTopic[indexPath.row]
        cell?.textLabel?.text = subtitle
        return cell!
    }
}

extension GuidelineContentController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.CellContentHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let menuRow = self.menuRows[section]
        if section == 0 {
            return GuidelineMainNotice(frame: .zero, titleText: menuRow.title, subtitleText: nil)
        }
        let view = ContentTitleView(frame: .zero, titleText: menuRow.title)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleContentHeaderTap))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view.tag = section
        view.addGestureRecognizer(tapRecognizer)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuRow = self.menuRows[indexPath.section]
        let subtitle = menuRow.subTopic[indexPath.row]
        let path = menuRow.title + "/" + subtitle
        ref?.child(path).observe(DataEventType.value, with: { (snapshot) in
            let contents = snapshot.value as? [String : AnyObject] ?? [:]
            for content in contents {
                print(content)
            }
        })
    }
    
    @objc func handleContentHeaderTap(sender: UIGestureRecognizer)
    {
        if let tag = sender.view?.tag {
            let menuRow = self.menuRows[tag]
            menuRow.isOpen = !menuRow.isOpen
            if menuRow.subTopic.count == 0 {
                ref?.child(menuRow.title).observe(DataEventType.value, with: { (snapshot) in
                    let contents = snapshot.value as? [String : AnyObject] ?? [:]
                    for content in contents {
                        menuRow.subTopic.append(content.key)
                        self.tableView.reloadData()
                    }
                })
            }
            self.tableView.reloadData()
        }
    }
}

class ContentTitleView: UIView {
    let title: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        return label
    }()
    
    let icon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "cross"))
        imageView.isUserInteractionEnabled = false
        constrain(imageView) {
            $0.height == 20
            $0.width == 20
        }
        return imageView
    }()
    
    init(frame: CGRect, titleText: String) {
        super.init(frame: frame)
        
        self.backgroundColor = .lightGray
        title.text = titleText
        
        self.addSubview(title)
        self.addSubview(icon)
        
        let margin: CGFloat = 20.0
        constrain(title, icon) { title, icon in
            title.left == title.superview!.left + margin
            title.centerY == title.superview!.centerY
            
            icon.left == title.right + 20
            icon.right == icon.superview!.right - margin
            icon.centerY == icon.superview!.centerY
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
