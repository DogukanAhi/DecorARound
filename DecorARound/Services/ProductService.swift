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
                let product = Product(category: data["category"] as? String,
                                      imageUrl: data["imageUrl"] as? String,
                                      name: data["name"] as? String,
                                      price: data["price"] as? Double,
                                      productId: data["productId"] as? String)
                products.append(product)
                
            }
            print("product eklendi!")
            completion(products)
        
        }
    }
}
