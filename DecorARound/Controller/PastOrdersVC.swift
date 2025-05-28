import UIKit
import FirebaseFirestore
import FirebaseAuth
import Kingfisher
import SwiftUI

struct PastOrderItem {
    let date: Date
    let total: Double
    let products: [(product: Product, quantity: Int)]
}

class PastOrdersVC: UIViewController {

    @IBOutlet weak var pastOrdersTableView: UITableView!

    var orders: [PastOrderItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        pastOrdersTableView.delegate = self
        pastOrdersTableView.dataSource = self
        pastOrdersTableView.estimatedRowHeight = 120
        pastOrdersTableView.rowHeight = UITableView.automaticDimension
        pastOrdersTableView.showsVerticalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPastOrders()
    }
    
    func fetchPastOrders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("Users").document(userId).collection("Orders").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching orders: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No orders found.")
                return
            }

            var tempOrders: [PastOrderItem] = []
            let dispatch = DispatchGroup()

            for doc in documents {
                let data = doc.data()
                let timestamp = data["orderDate"] as? Timestamp ?? Timestamp(date: Date())
                let total = data["totalAmount"] as? Double ?? 0.0
                let productsData = data["products"] as? [[String: Any]] ?? []

                var productTuples: [(Product, Int)] = []

                for item in productsData {
                    guard let productId = item["productId"] as? String,
                          let quantity = item["quantity"] as? Int else { continue }

                    dispatch.enter()
                    Firestore.firestore().collection("Products")
                        .whereField("productId", isEqualTo: productId)
                        .getDocuments { snap, error in
                            defer { dispatch.leave() }
                            if let doc = snap?.documents.first {
                                let data = doc.data()
                                let stock = data["stock"] as? [String: Int] ?? [:]
                                let images = data["imageUrl"] as? [String] ?? []
                                let firstImage = images.first ?? ""

                                let product = Product(
                                    category: data["category"] as? String,
                                    imageUrl: [firstImage],
                                    name: data["name"] as? String,
                                    price: data["price"] as? Double,
                                    productId: data["productId"] as? String,
                                    description: data["description"] as? String,
                                    rating: data["rating"] as? Double,
                                    stock: stock
                                )
                                productTuples.append((product, quantity))
                            }
                        }
                }

                dispatch.notify(queue: .main) {
                    let order = PastOrderItem(date: timestamp.dateValue(), total: total, products: productTuples)
                    tempOrders.append(order)
                    self.orders = tempOrders.sorted { $0.date > $1.date }
                    self.pastOrdersTableView.reloadData()
                }
            }
        }
    }

    func showRating(for products: [(Product, Int)]) {
        let ratingView = RateProductsView(products: products)
        let controller = UIHostingController(rootView: ratingView)
        controller.modalPresentationStyle = .popover
        self.present(controller, animated: true)
    }
}

extension PastOrdersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PastOrdersCell") as? PastOrdersCell else {
            return UITableViewCell()
        }

        let order = orders[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .long

        cell.dateLbl.text = formatter.string(from: order.date)
        cell.totalLbl.text = String(format: "$%.2f", order.total)
        cell.productImages = order.products.compactMap { $0.product.imageUrl?.first }
        cell.imageCollectionView.reloadData()

        cell.onRateTapped = { [weak self] in
            self?.showRating(for: order.products)
        }

        if let layout = cell.imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            layout.itemSize = CGSize(width: 60, height: 60)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
