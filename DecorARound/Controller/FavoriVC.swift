import UIKit
import FirebaseAuth
import FirebaseFirestore

class FavoriVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var selectedProductDict: [String: Any]?
    var favoriteProducts: [Product] = []
    let productService = ProductService()


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoriItems()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func loadFavoriItems() {
        
        favoriteProducts.removeAll()
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let userRef = Firestore.firestore().collection("Users").document(userId)

        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data(), error == nil else {
                print("❌ Error loading user favorites: \(error?.localizedDescription ?? "unknown")")
                return
        }

        guard let favorites = data["favorites"] as? [String] else { return }

        let dispatchGroup = DispatchGroup()
            
        for productId in favorites {
            dispatchGroup.enter()
            self.productService.fetchProduct(byId: productId) { product in
                defer { dispatchGroup.leave() }
                guard let product = product else { return }

                self.favoriteProducts.append(product)
            }
        }

        dispatchGroup.notify(queue: .main) {
            // Favori ürünler array'ini yazdır
            for product in self.favoriteProducts {
                print("Favorite Product: \(product.name ?? "No name") | Product ID: \(product.productId ?? "No ID") | Price: \(product.price ?? 0.0)")
            }
            self.collectionView.reloadData()
          }
    
        }
            
    }

}

extension FavoriVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriCell", for: indexPath) as! FavoriCell
         let product = favoriteProducts[indexPath.row]
         cell.priceLbl.text = String(format: "$%.2f", product.price ?? 0.0)
        cell.nameLbl.text = product.name
         DispatchQueue.main.async {
             if let firstImageUrl = product.imageUrl?.first, let url = URL(string: firstImageUrl) {
                     cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
                 
             } else {
                 cell.imageView.image = UIImage(systemName: "photo")
             }
         }
        
         return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = favoriteProducts[indexPath.row]
        selectedProductDict = [
                    "name": selectedProduct.name ?? "",
                    "price": selectedProduct.price ?? 0.0,
                    "imageUrl": selectedProduct.imageUrl ?? [],
                    "description": selectedProduct.description ?? "",
                    "rating": selectedProduct.rating ?? 0.0,
                    "stock": selectedProduct.stock ?? 0,
                    "productId": selectedProduct.productId ?? ""
                ]
        // Farklı storyboard'dan ProductDetailVC'yi instantiate etme
                let storyboard = UIStoryboard(name: "Search", bundle: nil)
        if let productDetailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailVC {
                // ProductDetailVC'ye verileri aktarma
                productDetailVC.productDetails = selectedProductDict
                self.navigationController?.pushViewController(productDetailVC, animated: true)
            
            }
                            
        }
}
