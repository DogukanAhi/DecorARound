import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProductDetailVC: UIViewController {
    
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var qtyButton: UIButton!
    @IBOutlet weak var stepperBtn: UIStepper!
    @IBOutlet weak var arButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cardButton: UIButton!
    
    var selectedQuantity: Int = 1
    var imageUrls: [String] = []
    var productDetails: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil {
            self.setupViewController()
        }
        // addCommentToProduct()
        if let layout = detailCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        detailCollectionView.showsHorizontalScrollIndicator = false
        detailCollectionView.decelerationRate = .fast
        detailCollectionView.isPagingEnabled = true
        detailCollectionView.dataSource = self
        detailCollectionView.delegate = self
        
        if let details = productDetails {
            imageUrls = details["imageUrl"] as? [String] ?? []
            titleLbl.text = details["name"] as? String ?? "Unknown Product"
            detailLbl.text = details["description"] as? String ?? "No Description Available"
            priceLabel.text = String(format: "$%.2f", details["price"] as? Double ?? 0.0)
            
            let rating = details["rating"] as? Double ?? 0.0
            rateButton.setTitle("\(rating)", for: .normal)
            updateRatingButtonColor(rating: rating)
            
            if let stockDict = details["stock"] as? [String: Int] {
                let totalStock = stockDict.values.reduce(0, +)
                stepperBtn.maximumValue = Double(totalStock)
            }
        }
    }
    func addCommentToProduct() {
            let db = Firestore.firestore()
            let productId = "1"
            let commentData: [String: Any] = [
                "userEmail": Auth.auth().currentUser?.email ?? "unknown",
                "rating": 5,
                "commentText": "WOAW VERY GOOD PRODUCT MY WIFE LOVED IT I HIGHLY RECOMMEND IT!",
                "date": Timestamp(date: Date())
            ]

            db.collection("Comments")
              .document(productId)
              .collection("userComments")
              .addDocument(data: commentData)

        }
    
    private func setupViewController() {
        favoriteButton.isEnabled = false
        arButton.isEnabled = false
        qtyButton.isEnabled = false
        cardButton.isEnabled = false
        stepperBtn.isEnabled = false
    }
    
    private func updateRatingButtonColor(rating: Double) {
        switch rating {
        case 0.0..<1.0:
            rateButton.tintColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0) // Koyu kırmızı
        case 1.0..<2.0:
            rateButton.tintColor = UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0) // Turuncumsu kırmızı
        case 2.0..<3.0:
            rateButton.tintColor = UIColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 1.0) // Sarımsı
        case 3.0..<4.0:
            rateButton.tintColor = UIColor(red: 0.4, green: 0.8, blue: 0.0, alpha: 1.0) // Açık yeşil
        case 4.0...5.0:
            rateButton.tintColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0) // Koyu yeşil
        default:
            rateButton.backgroundColor = UIColor.lightGray // Varsayılan renk
        }
    }
    
    @IBAction func addToCardClicked(_ sender: Any) {
        guard let productId = productDetails?["productId"] as? String,
              let userId = Auth.auth().currentUser?.uid else {
            Router.makeAlert(titleInput: "Error", messageInput: "You must be logged in to add items to your cart.", viewController: self)
            return
        }
        
        let selectedQuantity = Int(stepperBtn.value)
        let db = Firestore.firestore()
        let cartItemRef = db.collection("Carts").document(userId).collection("items").document(productId)
        
        // 🔁 Önce mevcut quantity'yi al, sonra ekle
        cartItemRef.getDocument { snapshot, error in
            var existingQuantity = 0
            
            if let data = snapshot?.data(), let qty = data["quantity"] as? Int {
                existingQuantity = qty
            }
            
            let newQuantity = existingQuantity + selectedQuantity
            
            cartItemRef.setData([
                "quantity": newQuantity
            ], merge: true) { error in
                if let error = error {
                    print("❌ Error adding to cart: \(error.localizedDescription)")
                } else {
                    Router.makeAlert(titleInput: "Added", messageInput: "Product Successfully Added to Cart", viewController: self)
                }
            }
        }
    }
    
    
    @IBAction func stepperClicked(_ sender: UIStepper) {
        selectedQuantity = Int(sender.value)
        qtyButton.setTitle("\(selectedQuantity)", for: .normal)
    }
    
    @IBAction func stockButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toStockVC", sender: nil)
    }
    
    @IBAction func arButtonClicked(_ sender: Any) {
        if let arVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArVC") as? ArVC {
            arVC.modalPresentationStyle = .fullScreen
            present(arVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func favoriteButtonClicked(_ sender: Any) {
        Router.makeAlert(titleInput: "Favorite", messageInput: "Product Added to Favorite", viewController: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toStockVC",
           let stockVC = segue.destination as? StockVC {
            stockVC.productStock = productDetails?["stock"] as? [String: Int] ?? [:]
        }
        if segue.identifier == "toCommentVC",
           let commentVC = segue.destination as? CommentVC,
           let productId = productDetails?["productId"] as? String {
            commentVC.productId = productId
        }
            
        
    }
}

extension ProductDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductDetailCell", for: indexPath) as! ProductDetailCell
        let imageUrl = imageUrls[indexPath.row]
        cell.configure(imageUrl: imageUrl, currentPage: indexPath.row, totalPages: imageUrls.count)
        return cell
    }
}
