import UIKit
import PassKit
import FirebaseFirestore
import FirebaseAuth

class PaymentDetailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cardNoTextFiled: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var adressTextView: UITextView!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var totalPriceField: UILabel!
    @IBOutlet weak var agree1Btn: UIButton!
    @IBOutlet weak var agree2Btn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var orderBtn: UIButton!

    var totalAmount: Double = 0.0
    var isAgree1 = false
    var isAgree2 = false

    var purchasedProductIDs: [String] = []
    var productQuantities: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        totalPriceField.text = String(format: "$%.2f", totalAmount)
        configureInitialUI()

        cardNoTextFiled.delegate = self
        cvvTextField.delegate = self
        cardNoTextFiled.keyboardType = .numberPad
        cvvTextField.keyboardType = .numberPad

        cardNoTextFiled.addTarget(self, action: #selector(formFieldsChanged), for: .editingChanged)
        cvvTextField.addTarget(self, action: #selector(formFieldsChanged), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(formFieldsChanged), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateForm()
    }

    func configureInitialUI() {
        adressTextView.isEditable = false
        adressTextView.backgroundColor = UIColor.systemGray5

        saveBtn.isEnabled = false
        saveBtn.tintColor = .gray
        editBtn.isEnabled = true
        editBtn.tintColor = .systemBlue

        agree1Btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        agree2Btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        agree1Btn.tintColor = .gray
        agree2Btn.tintColor = .gray

        orderBtn.isEnabled = false
        orderBtn.tintColor = .gray
    }

    @IBAction func editBtnClicked(_ sender: Any) {
        adressTextView.isEditable = true
        adressTextView.backgroundColor = .white
        saveBtn.isEnabled = true
        saveBtn.tintColor = .systemBlue
        editBtn.isEnabled = false
        editBtn.tintColor = .gray
    }

    @IBAction func saveBtnClicked(_ sender: Any) {
        adressTextView.isEditable = false
        adressTextView.backgroundColor = UIColor.systemGray5
        saveBtn.isEnabled = false
        saveBtn.tintColor = .gray
        editBtn.isEnabled = true
        editBtn.tintColor = .systemBlue
    }

    @IBAction func agree1BtnClicked(_ sender: UIButton) {
        isAgree1.toggle()
        let imageName = isAgree1 ? "checkmark.circle.fill" : "checkmark.circle"
        agree1Btn.setImage(UIImage(systemName: imageName), for: .normal)
        agree1Btn.tintColor = isAgree1 ? .systemGreen : .gray
        validateForm()
    }

    @IBAction func agree2BtnClicked(_ sender: UIButton) {
        isAgree2.toggle()
        let imageName = isAgree2 ? "checkmark.circle.fill" : "checkmark.circle"
        agree2Btn.setImage(UIImage(systemName: imageName), for: .normal)
        agree2Btn.tintColor = isAgree2 ? .systemGreen : .gray
        validateForm()
    }

    @objc func formFieldsChanged() {
        validateForm()
    }

    func validateForm() {
        let cardValid = !(cardNoTextFiled.text?.isEmpty ?? true)
        let cvvValid = (cvvTextField.text?.count == 3)
        let selectedDate = Calendar.current.startOfDay(for: datePicker.date)
        let today = Calendar.current.startOfDay(for: Date())
        let dateValid = selectedDate >= today
        let allAgreed = isAgree1 && isAgree2

        orderBtn.isEnabled = cardValid && cvvValid && dateValid && allAgreed
        orderBtn.tintColor = orderBtn.isEnabled ? .systemGreen : .gray
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        guard string.rangeOfCharacter(from: allowedCharacters.inverted) == nil else { return false }
        if textField == cvvTextField {
            let current = textField.text ?? ""
            let updated = (current as NSString).replacingCharacters(in: range, with: string)
            return updated.count <= 3
        }
        return true
    }

    @IBAction func orderBtnClicked(_ sender: Any) {
        presentApplePaySheet()
    }

    func presentApplePaySheet() {
        let item = PKPaymentSummaryItem(label: "DecorAround", amount: NSDecimalNumber(value: totalAmount))
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.dogukanahi.DecorARound1"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.paymentSummaryItems = [item]

        guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
            print("❌ Apple Pay not available.")
            return
        }
        paymentVC.delegate = self
        present(paymentVC, animated: true)
    }

    func updateFirestoreStockAndSales() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userId)

        for productId in purchasedProductIDs {
            let quantity = productQuantities[productId] ?? 1

            db.collection("Products").whereField("productId", isEqualTo: productId).getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else {
                    print("❌ Product not found: \(productId)")
                    return
                }

                let docID = document.documentID
                let productRef = db.collection("Products").document(docID)

                db.runTransaction({ (transaction, _) -> Any? in
                    let snapshot: DocumentSnapshot
                    do {
                        snapshot = try transaction.getDocument(productRef)
                    } catch {
                        print("❌ Snapshot fetch failed")
                        return nil
                    }

                    guard let stockAny = snapshot.data()?["stock"] as? [String: Any] else {
                        print("❌ Invalid or missing stock field")
                        return nil
                    }

                    var stockDict: [String: Int] = [:]
                    for (key, value) in stockAny {
                        if let val = value as? Int {
                            stockDict[key] = val
                        } else if let num = value as? NSNumber {
                            stockDict[key] = num.intValue
                        }
                    }

                    let randomCity = stockDict.keys.randomElement() ?? "Istanbul"
                    if let current = stockDict[randomCity], current >= quantity {
                        stockDict[randomCity] = current - quantity
                    }

                    let sold = snapshot.data()?["sold"] as? Int ?? 0

                    transaction.updateData([
                        "stock": stockDict,
                        "sold": sold + quantity
                    ], forDocument: productRef)

                    return nil
                }) { (_, error) in
                    if let error = error {
                        print("❌ Transaction failed: \(error.localizedDescription)")
                    } else {
                        print("✅ Product updated: \(productId)")
                    }
                }

                // Kullanıcının sold alanı güncelle
                let soldFieldPath = "sold.\(productId)"
                let update: [String: Any] = [
                    soldFieldPath: [
                        "quantity": FieldValue.increment(Int64(quantity)),
                        "lastPurchased": FieldValue.serverTimestamp()
                    ]
                ]

                userRef.setData(update, merge: true) { error in
                    if let error = error {
                        print("❌ User sold update failed: \(error.localizedDescription)")
                    } else {
                        print("✅ User sold field updated: \(productId)")
                    }
                }
            }
        }
    }
}

extension PaymentDetailVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) {
            self.updateFirestoreStockAndSales()
            self.saveOrderToFirestore()

            let alert = UIAlertController(title: "Payment Successful",
                                          message: "Your payment has been simulated successfully.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    func saveOrderToFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        let orderRef = db.collection("Users").document(userId).collection("Orders").document()

        var productArray: [[String: Any]] = []

        for productId in purchasedProductIDs {
            let quantity = productQuantities[productId] ?? 1
            productArray.append([
                "productId": productId,
                "quantity": quantity
            ])
        }

        let orderData: [String: Any] = [
            "orderDate": Timestamp(date: Date()),
            "totalAmount": totalAmount,
            "products": productArray,
            "address": adressTextView.text ?? "",
            "status": "completed"
        ]

        orderRef.setData(orderData) { error in
            if let error = error {
                print("❌ Sipariş kaydı hatası: \(error.localizedDescription)")
            } else {
                print("✅ Sipariş Firestore'a kaydedildi.")
            }
        }
    }
}
