import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct RatedProduct: Identifiable {
    let id: String
    let product: Product
    let quantity: Int
}

struct RateProductsView: View {
    var products: [(product: Product, quantity: Int)]
    @Environment(\.presentationMode) var presentationMode

    @State private var ratings: [String: Int] = [:] // productId -> rating
    @State private var comments: [String: String] = [:] // productId -> comment

    var ratedProducts: [RatedProduct] {
        products.map {
            RatedProduct(id: $0.product.productId ?? UUID().uuidString,
                         product: $0.product,
                         quantity: $0.quantity)
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(ratedProducts) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            if let url = URL(string: item.product.imageUrl?.first ?? "") {
                                AsyncImage(url: url) { image in
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                            }

                            VStack(alignment: .leading) {
                                Text(item.product.name ?? "Unknown")
                                    .font(.headline)
                                Text("Quantity: \(item.quantity)")
                                    .font(.subheadline)
                            }
                        }

                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: ratings[item.id] ?? 0 >= star ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        ratings[item.id] = star
                                    }
                            }
                        }

                        TextField("Leave a comment...", text: Binding(
                            get: { comments[item.id] ?? "" },
                            set: { comments[item.id] = $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Rate Your Orders ⭐️")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitRatings()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    func submitRatings() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        for product in ratedProducts {
            let productId = product.id
            let commentData: [String: Any] = [
                "userEmail": user.email ?? "unknown",
                "rating": ratings[productId] ?? 0,
                "commentText": comments[productId] ?? "",
                "date": Timestamp(date: Date())
            ]

            db.collection("Comments")
              .document(productId)
              .collection("userComments")
              .addDocument(data: commentData)
        }

        presentationMode.wrappedValue.dismiss()
    }
}
