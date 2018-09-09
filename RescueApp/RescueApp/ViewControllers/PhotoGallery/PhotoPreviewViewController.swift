//
/*
 PhotoPreviewViewController.swift
 Created on: 23/8/18
 
 Abstract:
  this will be the photo preview
 
 */

import UIKit
import FirebaseStorage
import FirebaseDatabase

class PhotoPreviewViewController: UIViewController {
    
    
    // MARK: Properties
    /// PUBLIC
    var photo: Photo!
    
    ///PRIVATE
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var commentTextField: UITextField!
    private var ref: DatabaseReference?
    private var image: UIImage? = UIImage(named: "placeholder.jpg")
    private let storageRef: StorageReference =  Storage.storage().reference()
    private var comments = [PhotoComment]()
    private struct C {
        struct FirebaseKeys {
            static let root = "heros_of_India_comments"
        }
        static let BOTTOM_PADDING_COMMENT_CONTAINER: CGFloat = 10
    }
    @IBOutlet weak var commentSectionBottomConstraint: NSLayoutConstraint!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIFromDidLoad()
        downloadImage()
        loadComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscriberKeyboardNotifications()
    }
    
    // MARK: Button actions
    
    @objc func onTap(_ recogniser: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSend() {
        guard let comment = commentTextField.text else {
            return
        }
        
        sendComment(comment)
    }
}

// MARK: Helper methods

private extension PhotoPreviewViewController {
    
    func configureUIFromDidLoad() {
        title = photo.name
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        commentTextField.resignFirstResponder()
    }
    
    /**
     downloads the image from the server
     
     */
    func downloadImage() {
        guard let url = photo.url else {
            return
        }
        
        Overlay.shared.show()
        // Create a reference to the file you want to download
        let imageRef = storageRef.child(url)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        imageRef.getData(maxSize: 1 * 1024 * 1024 * 1024) { [weak self] (data, error) in
            Overlay.shared.remove()
            if let error = error {
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                let tempImage = UIImage(data: data!)
                self?.image = tempImage
                self?.refreshTableView()
            }
        }
    }
    
    /**
     loads the comments for the photo
     
     */
    func loadComments() {
        guard let photoID = photo.id else {
            return
        }
        ref = Database.database().reference()
        ref?.child("\(C.FirebaseKeys.root)/\(photoID)")
            .observe(DataEventType.value, with: { [weak self] (snapshot) in
                let contents = snapshot.value as? [String : AnyObject] ?? [:]
                if let listComments = Array(contents.values) as? [[String: AnyObject]] {
                    var tempComments = [PhotoComment]()
                    for dict in listComments {
                        let photoComment = PhotoComment(dict)
                        tempComments.append(photoComment)
                    }
                    self?.comments = tempComments
                    self?.refreshTableView()
                }
            })
    }
    
    /**
     refreshs the tableview
     
     */
    func refreshTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    /**
     sends the comment to the firebase
     
     - parameters:
        - comment: string which will be saved with the timestamp to the server for the respective photo
     - todo: add author info too
     */
    func sendComment(_ comment: String) {
        Overlay.shared.show()
        let now = String(Int(Date().timeIntervalSince1970))
        if let photoID = photo.id {
            ref = Database.database().reference()
            ref?.child(C.FirebaseKeys.root)
                .child(photoID)
                .updateChildValues([now: ["comment": comment, "timestamp": now, "isValidated": false]]) { [weak self] (data, error) in
                    Overlay.shared.remove()
                    self?.commentTextField.text = nil
            }
        }
    }
}

// MARK: PhotoPreviewViewController -> UITableViewDataSource, UITableViewDelegate

extension PhotoPreviewViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        default: return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "imageCell")
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.image = image
            let description = cell.viewWithTag(2) as! UILabel
            description.text = photo.story
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "commentCell")
            let commentLabel = cell.viewWithTag(1) as! UILabel
            let authorLabel = cell.viewWithTag(2) as! UILabel
            let timestampLabel = cell.viewWithTag(3) as! UILabel
            
            let comment = comments[indexPath.row]
            commentLabel.text = comment.content
            authorLabel.text = comment.author
            timestampLabel.text = comment.formattedDate
        }
        cell?.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        default: return "Comments"
        }
    }
}

extension PhotoPreviewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: MemeEditorViewController: Notification Helpers
extension PhotoPreviewViewController {
    func subscribeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShown), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscriberKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: nil)
    }
    
    @objc func keyboardShown(notification: Notification) {
        commentSectionBottomConstraint.constant =
            getKeyboardHeight(notification) + C.BOTTOM_PADDING_COMMENT_CONTAINER
    }
    
    @objc func keyboardHide(notification: Notification) {
        commentSectionBottomConstraint.constant = C.BOTTOM_PADDING_COMMENT_CONTAINER
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
