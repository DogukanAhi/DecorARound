import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        guard let email = mailField.text, !email.isEmpty,
              let pwd = pwdField.text, !pwd.isEmpty else {
            Router.makeAlert(titleInput: "Error", messageInput: "Please Enter Username and Password",viewController: self)
            return }

        Auth.auth().createUser(withEmail: email, password: pwd) { authData, error in
            if let error {
                Router.makeAlert(titleInput: "Error", messageInput: error.localizedDescription,viewController: self)
            }else {
                print("User Created!")
                self.mailField.text = ""
                self.pwdField.text = ""
                self.performSegue(withIdentifier: "fromSignUptoMain", sender: nil)
            }
        }
    }
}
