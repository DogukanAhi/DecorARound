import UIKit
import FirebaseAuth

class LoginVC: UIViewController{
    
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var createAccountLbl: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(createAccountLblClicked))
        createAccountLbl.isUserInteractionEnabled = true
        createAccountLbl.addGestureRecognizer(tapGesture)
        Router.addTapGestureToDismissKeyboard(for: self.view)
    }
    
    
    @objc func createAccountLblClicked() {
        self.performSegue(withIdentifier: "toSignUpVC", sender: nil)
        
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        guard let email = mailField.text, !email.isEmpty,
              let pwd = pwdField.text, !pwd.isEmpty else {
        Router.makeAlert(titleInput: "Error", messageInput: "Please Enter Username and Password",viewController: self);return }
        Auth.auth().signIn(withEmail: email, password: pwd) { (auth,error) in
            
            if let error{
                Router.makeAlert(titleInput: "Error", messageInput: error.localizedDescription,viewController: self)
            }else{
                print("Login Success!")
                self.mailField.text = ""
                self.pwdField.text = ""
                self.performSegue(withIdentifier: "fromLogintoMain", sender: nil)
            }
        }
    }
}
