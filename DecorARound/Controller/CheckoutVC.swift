import UIKit
import FirebaseAuth
import FirebaseFirestore

class CheckoutVC: UIViewController {
    var selectedProducts: [Product] = []
    let productService = ProductService()
    var totalStocks: [String: Int] = [:]
    var quantities: [String: Int] = [:]

    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var checkoutBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCartItems()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateTotalPrice()
            self.checkoutBtn.isEnabled = !self.selectedProducts.isEmpty
        }
    }

    func loadCartItems() {
        selectedProducts.removeAll()
        quantities.removeAll()
        totalStocks.removeAll()
        print("loadCartItem called")
        guard let userId = Auth.auth().currentUser?.uid else { print("kullanıcı yok"); return }

        let cartRef = Firestore.firestore().collection("Carts").document(userId).collection("items")

        cartRef.getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents, error == nil else {
                print("❌ Error loading cart items: \(error?.localizedDescription ?? "unknown")")
                return
            }

            let dispatchGroup = DispatchGroup()

            for doc in documents {
                let productId = doc.documentID
                let quantity = doc.data()["quantity"] as? Int ?? 1

                self.quantities[productId] = quantity

                dispatchGroup.enter()
                self.productService.fetchProduct(byId: productId) { product in
                    defer { dispatchGroup.leave() }
                    guard let product = product else { return }

                    let totalStock = product.stock?.values.reduce(0, +) ?? 0
                    self.totalStocks[productId] = totalStock

                    if !self.selectedProducts.contains(where: { $0.productId == productId }) {
                        self.selectedProducts.append(product)
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.collectionView.reloadData()
                self.updateTotalPrice()
            }
        }
    }

    func updateTotalPrice() {
        var total: Double = 0.0

        for product in selectedProducts {
            let productId = product.productId ?? ""
            let price = product.price ?? 0.0
            let quantity = quantities[productId] ?? 1

            total += price * Double(quantity)
        }

        if selectedProducts.isEmpty {
            totalPriceLbl.text = "$0.00"
            checkoutBtn.isEnabled = false
            checkoutBtn.tintColor = .darkGray
        } else {
            checkoutBtn.isEnabled = true
            checkoutBtn.tintColor = .green
            totalPriceLbl.text = String(format: "$%.2f", total)
        }
    }
}

extension CheckoutVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CheckoutCell", for: indexPath) as! CheckoutCell

        let product = selectedProducts[indexPath.row]
        let productId = product.productId ?? ""
        let totalStockForProduct = totalStocks[productId] ?? 1
        let quantity = quantities[productId] ?? 1

        cell.productNameLbl.text = product.name
        cell.priceLbl.text = String(format: "$%.2f", product.price ?? 0.0)
        cell.qtyLbl.text = "\(quantity)"
        cell.strepper.value = Double(quantity)
        cell.strepper.maximumValue = Double(totalStockForProduct)
        cell.strepper.minimumValue = 1

        if let imageUrlStr = product.imageUrl?.first, let url = URL(string: imageUrlStr) {
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        } else {
            cell.imageView.image = UIImage(systemName: "photo")
        }

        cell.onStepperChange = { [weak self] newQty in
            guard let self = self else { return }
            self.quantities[productId] = newQty
            self.updateTotalPrice()

            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore()
                    .collection("Carts")
                    .document(userId)
                    .collection("items")
                    .document(productId)
                    .setData(["quantity": newQty], merge: true)
            }
        }

        cell.onDeleteTapped = { [weak self] in
            guard let self = self else { return }

            self.selectedProducts.removeAll { $0.productId == productId }
            self.quantities.removeValue(forKey: productId)
            self.totalStocks.removeValue(forKey: productId)

            if let userId = Auth.auth().currentUser?.uid {
                Firestore.firestore()
                    .collection("Carts")
                    .document(userId)
                    .collection("items")
                    .document(productId)
                    .delete()
            }

            self.collectionView.reloadData()
            self.updateTotalPrice()
        }

        return cell
    }
}
