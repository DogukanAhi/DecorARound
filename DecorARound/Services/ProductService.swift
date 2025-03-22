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
                
                // 📌 `imageUrl` dizisi olarak al, boşsa boş array dön
                let imageUrls = data["imageUrl"] as? [String] ?? []
                
                let product = Product(
                    category: data["category"] as? String,
                    imageUrl: imageUrls, // 📌 Artık bir `String` değil, `String Array`
                    name: data["name"] as? String,
                    price: data["price"] as? Double,
                    productId: data["productId"] as? String,
                    description: data["description"] as? String,
                    rating: data["rating"] as? Double,
                    stock: stockData
                )
                
                products.append(product)
            }
            
            print("✅ Ürünler başarıyla eklendi!")
            completion(products)
        }
    }
    func fetchProduct(byId id: String, completion: @escaping (Product?) -> Void) {
        db.collection("Products").whereField("productId", isEqualTo: id).getDocuments { snapshot, error in
            if let error = error {
                print("❌ Hata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(nil)
                return
            }
            
            let data = document.data()
            let stockData = data["stock"] as? [String: Int] ?? [:]
            let imageUrls = data["imageUrl"] as? [String] ?? []

            let product = Product(
                category: data["category"] as? String,
                imageUrl: imageUrls,
                name: data["name"] as? String,
                price: data["price"] as? Double,
                productId: data["productId"] as? String,
                description: data["description"] as? String,
                rating: data["rating"] as? Double,
                stock: stockData
            )

            completion(product)
        }
    }
}
