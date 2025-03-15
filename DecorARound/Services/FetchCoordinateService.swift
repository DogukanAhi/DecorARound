import Foundation
import FirebaseFirestore

struct FetchCoordinatesService {
    private let db = Firestore.firestore()

    private let cityCoordinates: [String: (latitude: Double, longitude: Double)] = [
        "Ankara": (39.92077, 32.85411),
        "Istanbul": (41.0082, 28.9784),
        "Izmir": (38.4192, 27.1287),
        "Gaziantep": (37.0662, 37.3833)
    ]

    func fetchStockCoordinates(stock: [String: Int], completion: @escaping ([(city: String, stock: Int, latitude: Double, longitude: Double)]) -> Void) {
        var stockData: [(city: String, stock: Int, latitude: Double, longitude: Double)] = []
        
        for (city, stockAmount) in stock {
            if let coordinates = cityCoordinates[city] {
                stockData.append((city: city, stock: stockAmount, latitude: coordinates.latitude, longitude: coordinates.longitude))
            }
        }
        
        completion(stockData)
    }
}

