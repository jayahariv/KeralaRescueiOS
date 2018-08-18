//
//  RescueSearchView.swift
//  RescueSearchView
//
//  Created by Nitin George on 8/17/18.
//  Copyright © 2018 Nitin George. All rights reserved.
//

import UIKit

typealias Tags = [String];

protocol RescueSearchViewDelegate: class {
    func didSelectTag(tag: String)
    func didUnselectTag(tag: String)
    func didSelectSearchButton(text: String)
}

class RescueSearchView: UIView {
    private var tagCollection: UICollectionView!
    private var searchBar: UISearchBar!
    private var tags: Tags!
    private var shouldSetupConstraints = true
    
    weak var delegate: RescueSearchViewDelegate? = nil
    
    init(with tags: Tags, frame: CGRect) {
        super.init(frame: frame)
        self.tags = tags
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
        alignedFlowLayout.estimatedItemSize = .init(width: 100, height: 40)
        alignedFlowLayout.minimumInteritemSpacing = 4
        searchBar = UISearchBar(frame: CGRect.zero)
        searchBar.delegate = self
        searchBar.placeholder = "Enter keywords"
        searchBar.barTintColor = .white
        searchBar.searchBarStyle = .minimal;
        searchBar.tintColor = .lightGray
        tagCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: alignedFlowLayout)
        tagCollection.backgroundColor = UIColor.white
        tagCollection.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(searchBar)
        self.addSubview(tagCollection)
        tagCollection.allowsMultipleSelection = true
        tagCollection.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tagcellreuseidentifier")
        tagCollection.dataSource = self
        tagCollection.delegate = self
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if shouldSetupConstraints {
            guard let collection = tagCollection else {
                return
            }
            shouldSetupConstraints = false
            let buttonLeftConstraint1 = searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            let buttonRightConstraint1 = searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            let buttonBottomConstraint1 = searchBar.bottomAnchor.constraint(equalTo: collection.topAnchor, constant: -8)
            let buttonTopConstraint1 = searchBar.topAnchor.constraint(equalTo: self.topAnchor)
            let heightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 44)
            
            let buttonLeftConstraint = collection.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8)
            let buttonRightConstraint = collection.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
            let buttonBottomConstraint = collection.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            NSLayoutConstraint.activate([buttonLeftConstraint1, buttonRightConstraint1, buttonBottomConstraint1, buttonTopConstraint1, buttonLeftConstraint, buttonRightConstraint, buttonBottomConstraint, heightConstraint])
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension RescueSearchView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagcellreuseidentifier", for: indexPath) as! TagCollectionViewCell
        cell.label.text = tags[indexPath.row]
        return cell
    }
}

extension RescueSearchView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.didSelectTag(tag: tags[indexPath.row])
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.didUnselectTag(tag: tags[indexPath.row])
    }
}

extension RescueSearchView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let delegate = self.delegate else {
            return
        }
        guard let text = searchBar.text else{
            return
        }
        delegate.didSelectSearchButton(text: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
