import Foundation
import FirebaseFirestore

struct ProductService {
    private let db = Firestore.firestore()
    func fetchProducts(completion: @escaping ([Product]) -> Void) {
        db.collection("Products").getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion([])
                return
            }
            var products = [Product]()
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                let stockData = data["stock"] as? [String: Int] ?? [:]
                let product = Product(category: data["category"] as? String,
                                      imageUrl: data["imageUrl"] as? String,
                                      name: data["name"] as? String,
                                      price: data["price"] as? Double,
                                      productId: data["productId"] as? String,
                                      description: data["description"] as? String,
                                      rating: data["rating"] as? Double,
                                      stock: stockData)
                                        
                products.append(product)
                
            }
            print("product eklendi!")
            completion(products)
        
        }
    }
}
