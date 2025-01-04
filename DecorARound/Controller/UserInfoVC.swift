import FirebaseAuth
import UIKit

class UserInfoVC: UIViewController {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var addressField: UITextView!
    @IBOutlet weak var editBtn: UIButton!
    
    private var userMail = Auth.auth().currentUser?.email
    private var editFlag : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFields()
        mailField.delegate = self
        Router.addTapGestureToDismissKeyboard(for: self.view)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.editFlag = false
    }
    private func setUpFields() {
        self.mailField.isUserInteractionEnabled = false
        self.pwdField.isUserInteractionEnabled = false
        self.addressField.isEditable = false
        self.pwdField.isSecureTextEntry = true
        self.mailField.text = self.userMail
    }
    
    private func isAllowedDomain( _ email:String) -> Bool {
        let allowedDomains = ["gmail.com", "hotmail.com", "outlook.com", "yahoo.com"]
        guard let domain = email.split(separator: "@").last else { return false }
        return allowedDomains.contains(String(domain))
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        Router.makeAlert(titleInput: "Successfully Edited!", messageInput: "You have successfully edited your profile", viewController: self)
        self.editBtn.tintColor = .systemBlue
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        switch(self.editFlag) {
        case false:
            self.editBtn.tintColor = .systemGray
            self.editFlag = true
            self.mailField.isUserInteractionEnabled = true
            self.pwdField.isUserInteractionEnabled = true
            self.addressField.isEditable = true
        case true:
            self.editFlag = false
            self.editBtn.tintColor = .systemBlue
            self.mailField.isUserInteractionEnabled = false
            self.pwdField.isUserInteractionEnabled = false
            self.addressField.isEditable = false
        }
    }
}

extension UserInfoVC: UITextFieldDelegate { //MARK: textFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == mailField {
            if isValidEmail(textField.text ?? "") {
                print("Geçerli e-posta.")
            } else {
                Router.makeAlert(titleInput: "Email Error", messageInput: "Please Enter Valid Mail Adress.", viewController: self)
                textField.text = ""
            }
        }
    }
}
