import FirebaseAuth
import UIKit

class UserInfoVC: UIViewController {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var editBtn: UIButton!
    
    private var userMail = Auth.auth().currentUser?.email
    private var editFlag : Bool = false
    private var originalEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalEmail = Auth.auth().currentUser?.email ?? ""
        setUpFields()
        mailField.delegate = self
        Router.addTapGestureToDismissKeyboard(for: self.view)
        addPasswordToggle()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.editFlag = false
    }
    private func setUpFields() {
        self.mailField.isUserInteractionEnabled = false
        self.pwdField.isUserInteractionEnabled = false
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
    
    private func addPasswordToggle() {
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        pwdField.rightView = eyeButton
        pwdField.rightViewMode = .always
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        pwdField.isSecureTextEntry.toggle()
        let imageName = pwdField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {
                print("🚫 User not logged in")
                return
            }

            guard let newEmail = mailField.text,
                  let password = pwdField.text,
                  !newEmail.isEmpty, !password.isEmpty else {
                Router.makeAlert(titleInput: "Error", messageInput: "Please fill in all fields.", viewController: self)
                return
            }

            if !isValidEmail(newEmail) || !isAllowedDomain(newEmail) {
                Router.makeAlert(titleInput: "Invalid Email", messageInput: "Please enter a valid email address.", viewController: self)
                return
            }

            let credential = EmailAuthProvider.credential(withEmail: originalEmail, password: password)
            print("🔐 Reauthenticating...")

            user.reauthenticate(with: credential) { [weak self] _, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Reauthentication failed: \(error.localizedDescription)")
                    Router.makeAlert(titleInput: "Authentication Failed", messageInput: error.localizedDescription, viewController: self)
                    return
                }

                print("✅ Reauthenticated. Now updating email...")

                user.updateEmail(to: newEmail) { emailError in
                    if let emailError = emailError {
                        print("❌ updateEmail error: \(emailError.localizedDescription)")
                        Router.makeAlert(titleInput: "Email Error", messageInput: emailError.localizedDescription, viewController: self)
                        return
                    }

                    print("📧 Email updated to \(newEmail)")

                    user.updatePassword(to: password) { pwdError in
                        if let pwdError = pwdError {
                            print("❌ updatePassword error: \(pwdError.localizedDescription)")
                            Router.makeAlert(titleInput: "Password Error", messageInput: pwdError.localizedDescription, viewController: self)
                            return
                        }

                        print("🔑 Password updated.")

                        user.reload { reloadError in
                            if let reloadError = reloadError {
                                print("🔄 Reload error: \(reloadError.localizedDescription)")
                                return
                            }

                            print("🔁 User reloaded.")
                            let updatedEmail = user.email ?? "N/A"
                            print("✅ Final Email: \(updatedEmail)")
                            self.userMail = updatedEmail
                            self.setUpFields()
                            self.updateUI(newEmail: updatedEmail)
                        }
                    }
                }
            }
    }
    
    private func updateUI(newEmail: String) {
            self.userMail = newEmail
            self.setUpFields()
            self.editBtn.tintColor = .systemBlue
            self.mailField.isUserInteractionEnabled = false
            self.pwdField.isUserInteractionEnabled = false
            self.editFlag = false

            Router.makeAlert(titleInput: "Success", messageInput: "Your profile has been updated.", viewController: self)
    }
    
    @IBAction func editBtnClicked(_ sender: Any) {
        switch(self.editFlag) {
        case false:
            self.editBtn.tintColor = .systemGray
            self.editFlag = true
            self.mailField.isUserInteractionEnabled = true
            self.pwdField.isUserInteractionEnabled = true
        case true:
            self.editFlag = false
            self.editBtn.tintColor = .systemBlue
            self.mailField.isUserInteractionEnabled = false
            self.pwdField.isUserInteractionEnabled = false
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
