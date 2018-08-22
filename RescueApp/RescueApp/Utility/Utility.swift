

import UIKit

struct Alert {
    static func errorAlert(title: String, message: String?, cancelButton: Bool = false, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) {
            _ in
            guard let completion = completion else { return }
            completion()
        }
        alert.addAction(actionOK)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if cancelButton { alert.addAction(cancel) }

        return alert
    }
}

final class Utility: NSObject {
    /**
     convert the given date to the given format
 
     - parameters:
         - date: date to be converted.
         - format: pass in the format string.
     - returns: formatted string from the date
     */
    static func formattedDate(date: Date?, format: String) -> String {
        guard let _date = date else {
            return "--"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: _date)
    }
}
