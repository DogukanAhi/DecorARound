class CartManager {
    static let shared = CartManager()
    
    private init() {}
    
    var pendingProductIds: [String] = []
    var pendingCartItems: [PendingCartItem] = []
}
