import UIKit
class CheckoutVC: UIViewController {
    var receivedProductId: String?
    var selectedProducts: [Product] = []
    let productService = ProductService()
    var totalStocks: [String: Int] = [:]
    private var totalStock: Int = 0
    var quantities: [String: Int] = [:]
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleProductAdded(_:)),
                                               name: Notification.Name("ProductAddedToCart"),
                                               object: nil)
        for productId in CartManager.shared.pendingProductIds {
            fetchAndAppendProduct(productId: productId)
        }
        for item in CartManager.shared.pendingCartItems {
            // ✅ Mevcut quantity varsa üstüne ekle
            let currentQty = self.quantities[item.productId] ?? 0
            self.quantities[item.productId] = currentQty + item.quantity

            self.fetchAndAppendProduct(productId: item.productId)
        }
        CartManager.shared.pendingProductIds.removeAll()
    }
    @objc func handleProductAdded(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let productId = userInfo["productId"] as? String {
            
            let newQty = userInfo["quantity"] as? Int ?? 1
            let currentQty = self.quantities[productId] ?? 0
            self.quantities[productId] = currentQty + newQty  // ✅ toplama burada

            productService.fetchProduct(byId: productId) { [weak self] product in
                guard let self = self, let product = product else { return }

                let totalStock = product.stock?.values.reduce(0, +) ?? 0
                self.totalStocks[product.productId ?? ""] = totalStock

                if !self.selectedProducts.contains(where: { $0.productId == product.productId }) {
                    self.selectedProducts.append(product)
                }

                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.updateTotalPrice()
                }
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
        
        totalPriceLbl.text = String(format: "Total: $%.2f", total)
    }

    
    
    func fetchAndAppendProduct(productId: String) {
        productService.fetchProduct(byId: productId) { [weak self] product in
            guard let self = self, let product = product else { return }
            
            // 🔢 totalStock hesapla ve kaydet
            let totalStock = product.stock?.values.reduce(0, +) ?? 0
            print("fetchAndAppendProduct → total stock: \(totalStock)")
            self.totalStocks[product.productId ?? ""] = totalStock
            
            // Ürünü ekle (eğer daha önce eklenmemişse)
            if !self.selectedProducts.contains(where: { $0.productId == product.productId }) {
                self.selectedProducts.append(product)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.updateTotalPrice() 
            }
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
        cell.onStepperChange = { [weak self] newQty in
            guard let self = self else { return }
            self.quantities[productId] = newQty
            self.updateTotalPrice()
        }

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
        return cell
        
    }
}
