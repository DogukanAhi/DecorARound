import UIKit

struct Router {
    static func makeAlert (titleInput: String, messageInput: String,viewController: UIViewController) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        viewController.present(alert,animated: true)
    }
}
