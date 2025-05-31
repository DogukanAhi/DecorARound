import FirebaseAuth
import UIKit

class UserInfoVC: UIViewController {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var newpwdField: UITextField!
    @IBOutlet weak var editBtn: UIButton!
    
    private var userMail = Auth.auth().currentUser?.email
        private var editFlag = false
        
        override func viewDidLoad() {
            super.viewDidLoad()
            userMail = Auth.auth().currentUser?.email
            setUpFields()
            mailField.delegate = self
            Router.addTapGestureToDismissKeyboard(for: self.view)
            addPasswordToggles()
        }
        
        private func setUpFields() {
            mailField.isUserInteractionEnabled = false
            pwdField.isUserInteractionEnabled = false
            newpwdField.isUserInteractionEnabled = false
            pwdField.isSecureTextEntry = true
            newpwdField.isSecureTextEntry = true
            mailField.text = userMail
        }
        
        private func addPasswordToggles() {
            addEyeToggle(to: pwdField, selector: #selector(togglePasswordVisibility(_:)))
            addEyeToggle(to: newpwdField, selector: #selector(toggleNewPasswordVisibility(_:)))
        }

        private func addEyeToggle(to textField: UITextField, selector: Selector) {
            let eyeButton = UIButton(type: .custom)
            eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            eyeButton.tintColor = .gray
            eyeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            eyeButton.addTarget(self, action: selector, for: .touchUpInside)
            textField.rightView = eyeButton
            textField.rightViewMode = .always
        }

        @objc private func togglePasswordVisibility(_ sender: UIButton) {
            toggleSecureTextEntry(for: pwdField, button: sender)
        }

        @objc private func toggleNewPasswordVisibility(_ sender: UIButton) {
            toggleSecureTextEntry(for: newpwdField, button: sender)
        }

        private func toggleSecureTextEntry(for textField: UITextField, button: UIButton) {
            textField.isSecureTextEntry.toggle()
            let imageName = textField.isSecureTextEntry ? "eye.slash" : "eye"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }

    
    @IBAction func saveBtnClicked(_ sender: Any) {
        guard let user = Auth.auth().currentUser else {
                print("User not logged in")
                return
            }

            guard let currentPassword = pwdField.text,
                  let newPassword = newpwdField.text,
                  !currentPassword.isEmpty, !newPassword.isEmpty else {
                Router.makeAlert(titleInput: "Error", messageInput: "Please fill in all fields.", viewController: self)
                return
            }
        
            guard currentPassword != newPassword else {
                Router.makeAlert(titleInput: "Error", messageInput: "New password must be different from the current password.", viewController: self)
                return
            }

            let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)

            print("Reauthenticating")

            user.reauthenticate(with: credential) { [weak self] _, error in
                guard let self = self else { return }

                if let error = error {
                    print("Reauthentication failed: \(error.localizedDescription)")
                    Router.makeAlert(titleInput: "Authentication Failed", messageInput: error.localizedDescription, viewController: self)
                    return
                }

                print("Reauthenticated. Updating password...")

                user.updatePassword(to: newPassword) { pwdError in
                    if let pwdError = pwdError {
                        print("Password update failed: \(pwdError.localizedDescription)")
                        Router.makeAlert(titleInput: "Update Failed", messageInput: pwdError.localizedDescription, viewController: self)
                        return
                    }

                    print("Password successfully updated.")
                    
                    self.setUpFields()
                    self.updateUI()
                }
            }
    }
    
    private func updateUI() {
        self.setUpFields()
        self.editBtn.tintColor = .systemBlue
        self.editFlag = false
        Router.makeAlert(titleInput: "Success", messageInput: "Your password has been updated.", viewController: self)
    }

    
    @IBAction func editBtnClicked(_ sender: Any) {
        switch(self.editFlag) {
        case false:
            self.editBtn.tintColor = .systemGray
            self.editFlag = true
            self.mailField.isUserInteractionEnabled = false
            self.pwdField.isUserInteractionEnabled = true
            self.newpwdField.isUserInteractionEnabled = true
        case true:
            self.editFlag = false
            self.editBtn.tintColor = .systemBlue
            self.mailField.isUserInteractionEnabled = false
            self.pwdField.isUserInteractionEnabled = false
            self.newpwdField.isUserInteractionEnabled = false
        }
    }
}

extension UserInfoVC: UITextFieldDelegate { //MARK: textFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == mailField {
                let email = textField.text ?? ""
                if !isValidEmail(email) {
                    Router.makeAlert(titleInput: "Email Error", messageInput: "Please Enter Valid Mail Address.", viewController: self)
                    textField.text = ""
                }
            }
        }

        private func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
        }
}
