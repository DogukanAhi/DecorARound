import UIKit
import Kingfisher
class ProductsVC: UIViewController {
    var category: Category?
    @IBOutlet weak var productCollectionView: UICollectionView!
    private var cellSize: CGSize!
    private var screenSize = UIScreen.main.bounds
    private var products: [Product] = []
    private let productService = ProductService()
    private var selectedProductDict: [String: Any]?
    @IBOutlet weak var searchBar: UISearchBar!
    private var allProducts: [Product] = []

    fileprivate  func prepareCellSize() {
        let width = ((screenSize.width-32)/2) * 0.9
        let height = width * 1.4
        cellSize = CGSize(width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCellSize()
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
        productCollectionView.showsVerticalScrollIndicator = false
        self.searchBar.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        self.fetchProducts()
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    private func fetchProducts() {
        guard let category = category?.title else { return }
        productService.fetchProducts { [weak self] result in
            let filtered = result.filter { $0.category == category }
            self?.allProducts = filtered
            self?.products = filtered
            DispatchQueue.main.async { // GCD vs. NSOperationQueue
                self?.productCollectionView.reloadData()
            }
        }
    }
}

extension ProductsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductsCell
        let product = products[indexPath.row]
        cell.priceLbl.text = String(format: "$%.2f", product.price ?? 0.0)
        cell.productNameLbl.text = product.name
        DispatchQueue.main.async {
            if let firstImageUrl = product.imageUrl?.first, let url = URL(string: firstImageUrl) {
                    cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
                
            } else {
                cell.imageView.image = UIImage(systemName: "photo")
            }
        }
       
        return cell
    }
    
}
extension ProductsVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.row]
        selectedProductDict = [
                    "name": selectedProduct.name ?? "",
                    "price": selectedProduct.price ?? 0.0,
                    "imageUrl": selectedProduct.imageUrl ?? [],
                    "description": selectedProduct.description ?? "",
                    "rating": selectedProduct.rating ?? 0.0,
                    "stock": selectedProduct.stock ?? 0,
                    "productId": selectedProduct.productId ?? ""
                ]
        if let istanbulStock = selectedProduct.stock?["Istanbul"] {
            print("İstanbul Stok: \(istanbulStock)")
        } else {
            print("İstanbul için stok bilgisi yok.")
        }
        
        self.performSegue(withIdentifier: "toProductDetailVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toProductDetailVC",
              let destinationVC = segue.destination as? ProductDetailVC {
               destinationVC.productDetails = selectedProductDict
           }
       }
}

extension ProductsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

extension ProductsVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            products = allProducts
        } else {
            let searchChar = searchText.lowercased().prefix(1)
            products = allProducts.filter {
                guard let name = $0.name?.lowercased(), let firstChar = name.first else { return false }
                return String(firstChar) == searchChar
            }
        }
        productCollectionView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
