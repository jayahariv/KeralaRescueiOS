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
import SafariServices

struct SubTopic {
    var title: String
    var url: String?
    var html: String?
}

class MenuRowItem {
    var title: String = ""
    var subTopic: [SubTopic] = []
    var isOpen: Bool = false
    
    init(withTitle title: String) {
        self.title = title
    }
}

class GuidelineContentController: UIViewController, RANavigationProtocol {
    private var headers: [Int: ContentTitleView] = [:]
    
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
        view.backgroundColor = .white
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = RAColorSet.TABLE_BACKGROUND
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.register(ContentTopicCell.self, forCellReuseIdentifier: ContentTopicCell.CellIndentifier)

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
        configureNavigationBar(RAColorSet.LIGHT_BLUE)
        
        tableView.isHidden = true
        Overlay.shared.showWithMessage(NSLocalizedString(Constants.LoadingDataFromServer, comment: ""))

        fetchData()
    }
    
    private func loadContents() {
        Overlay.shared.remove()
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func fetchData() {
        ApiClient.shared.getGuidelines(completion: { (menuRows) in
            Overlay.shared.remove()
            self.menuRows = menuRows
        })
    }
}



extension GuidelineContentController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuRows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let menuRow = self.menuRows[section]
        return menuRow.isOpen ? menuRow.subTopic.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ContentTopicCell.CellIndentifier) as! ContentTopicCell
        let subTopic = self.menuRows[indexPath.section].subTopic[indexPath.row]
        cell.initialize(withTitle: subTopic.title)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension GuidelineContentController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.CellContentHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let menuRow = self.menuRows[section]
        var view = headers[section]
        if view == nil {
            view = ContentTitleView(frame: .zero, titleText: menuRow.title, isExpanded: menuRow.isOpen)
            headers[section] = view
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleContentHeaderTap))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view?.tag = section
        view?.addGestureRecognizer(tapRecognizer)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuRow = self.menuRows[indexPath.section]
        let subTopic = menuRow.subTopic[indexPath.row]
        if let pageHtml = subTopic.html, !pageHtml.isEmpty {
            let webController = WebController(withPageHtml: pageHtml)
            navigationController?.pushViewController(webController, animated: true)
        } else {
            let safariView = SFSafariViewController(url: URL(string: subTopic.url!)!)
            navigationController?.present(safariView, animated: true)
        }
    }
    
    @objc func handleContentHeaderTap(sender: UIGestureRecognizer)
    {
        if let tag = sender.view?.tag, let headerView = sender.view as? ContentTitleView {
            let menuRow = self.menuRows[tag]
            menuRow.isOpen = !menuRow.isOpen
            headerView.toggle()
            self.tableView.reloadData()
        }
    }
}

class ContentTitleView: UIView {
    var isExpanded = false
    
    let title: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.textColor = RAColorSet.DARK_TEXT_COLOR
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        return label
    }()
    
    let icon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Expand"))
        imageView.isUserInteractionEnabled = false
        constrain(imageView) {
            $0.height == 20
            $0.width == 20
        }
        return imageView
    }()
    
    func toggle() {
        isExpanded = !isExpanded
        icon.image = isExpanded ? UIImage(named: "Collapse") : UIImage(named: "Expand")
    }
    
    init(frame: CGRect, titleText: String, isExpanded: Bool) {
        super.init(frame: frame)
        
        self.backgroundColor = RAColorSet.HEADER_BACKGROUD
        self.isExpanded = isExpanded
        icon.image = isExpanded ? UIImage(named: "Collapse") : UIImage(named: "Expand")
        title.text = titleText.uppercased()
        
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
