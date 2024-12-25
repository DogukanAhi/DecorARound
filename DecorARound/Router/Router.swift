import UIKit

struct Router {
    struct Segue {
        static func performSegue(from viewController: UIViewController, to identifier: String, sender: Any?) {
            viewController.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
}
