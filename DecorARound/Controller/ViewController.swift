import UIKit
import FirebaseFirestore
import Kingfisher

class ViewController: UIViewController {
    @IBOutlet weak var campaignCollectionView: UICollectionView!
    @IBOutlet weak var bestSellerCollectionView: UICollectionView!
    @IBOutlet weak var bestSellerTitleLabel: UILabel!

    var campaignImages: [UIImage] = [
        UIImage(named: "camp1")!,
        UIImage(named: "camp2")!,
        UIImage(named: "camp3")!
    ]

    var bestSellers: [Product] = []
    let productService = ProductService()

    private var selectedProductDict: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()

        campaignCollectionView.delegate = self
        campaignCollectionView.dataSource = self
        if let layout = campaignCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        campaignCollectionView.showsHorizontalScrollIndicator = false
        campaignCollectionView.decelerationRate = .fast
        campaignCollectionView.isPagingEnabled = true
        campaignCollectionView.reloadData()

        bestSellerCollectionView.delegate = self
        bestSellerCollectionView.dataSource = self
        bestSellerCollectionView.showsHorizontalScrollIndicator = false
        bestSellerCollectionView.showsVerticalScrollIndicator = false

        // Register Header
        let nib = UINib(nibName: "BestSellerHeaderView", bundle: nil)
        bestSellerCollectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "BestSellerHeaderView")

        fetchBestSellers()
    }

    func fetchBestSellers() {
        let db = Firestore.firestore()
        db.collection("Products")
            .order(by: "sold", descending: true)
            .limit(to: 6)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch best sellers: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }

                self?.bestSellers = documents.map { doc in
                    let data = doc.data()
                    return Product(
                        category: data["category"] as? String,
                        imageUrl: data["imageUrl"] as? [String] ?? [],
                        name: data["name"] as? String,
                        price: data["price"] as? Double,
                        productId: data["productId"] as? String,
                        description: data["description"] as? String,
                        rating: data["rating"] as? Double,
                        stock: data["stock"] as? [String: Int] ?? [:]
                    )
                }

                DispatchQueue.main.async {
                    self?.bestSellerCollectionView.reloadData()
                }
            }
    }

    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        let indexPath = IndexPath(item: page, section: 0)
        campaignCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    @IBAction func arButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toArVC", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProductDetailVC",
           let destinationVC = segue.destination as? ProductDetailVC {
            destinationVC.productDetails = selectedProductDict
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == campaignCollectionView {
            return campaignImages.count
        } else if collectionView == bestSellerCollectionView {
            return bestSellers.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == campaignCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CampaignCell", for: indexPath) as! CampaignCell
            cell.configure(image: campaignImages[indexPath.row], currentPage: indexPath.row, totalPages: campaignImages.count)
            return cell
        } else if collectionView == bestSellerCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BestSellerCell", for: indexPath) as! BestSellerCell
            let product = bestSellers[indexPath.row]
            cell.productNameLbl.text = product.name
            if let imageUrl = product.imageUrl?.first, let url = URL(string: imageUrl) {
                cell.productImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
            } else {
                cell.productImageView.image = UIImage(systemName: "photo")
            }
            cell.productImageView.contentMode = .scaleAspectFit
            cell.productImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cell.productImageView.heightAnchor.constraint(equalToConstant: 120),
                cell.productImageView.widthAnchor.constraint(equalToConstant: 120)
            ])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == bestSellerCollectionView && kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BestSellerHeaderView", for: indexPath) as! BestSellerHeaderView
            header.headerLbl.text = "Best Sellers"
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == bestSellerCollectionView {
            return CGSize(width: collectionView.frame.width, height: 40)
        }
        return CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bestSellerCollectionView {
            let selectedProduct = bestSellers[indexPath.row]
            selectedProductDict = [
                "name": selectedProduct.name ?? "",
                "price": selectedProduct.price ?? 0.0,
                "imageUrl": selectedProduct.imageUrl ?? [],
                "description": selectedProduct.description ?? "",
                "rating": selectedProduct.rating ?? 0.0,
                "stock": selectedProduct.stock ?? 0,
                "productId": selectedProduct.productId ?? ""
            ]
            let storyboard = UIStoryboard(name: "Search", bundle: nil)
            if let productDetailVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailVC {
                productDetailVC.productDetails = selectedProductDict
                self.navigationController?.pushViewController(productDetailVC, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == campaignCollectionView {
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
            return CGSize(width: width, height: height)
        } else if collectionView == bestSellerCollectionView {
            let totalSpacing: CGFloat = 20
            let width = (collectionView.bounds.width - totalSpacing) / 3
            return CGSize(width: width, height: width * 1.4)
        }
        return CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        for cell in campaignCollectionView.visibleCells {
            if let campaignCell = cell as? CampaignCell {
                campaignCell.pageControl.numberOfPages = campaignImages.count
                campaignCell.pageControl.currentPage = Int(pageIndex)
            }
        }
    }
}
