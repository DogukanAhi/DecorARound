import UIKit
import MapKit
class StockVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    private let fetchService = FetchCoordinatesService()
    var productStock: [String: Int] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        fetchStockAndAddAnnotations()
    }
    
    private func fetchStockAndAddAnnotations() {
        fetchService.fetchStockCoordinates(stock: productStock) { [weak self] stockData in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard !stockData.isEmpty else {
                    print("Stok bilgisi bulunamadı.")
                    return
                }
                var allStocksAreZero = true
                for stockInfo in stockData {
                    
                    if stockInfo.stock > 0 {
                        allStocksAreZero = false
                    }
                    if stockInfo.stock > 0 {
                        let annotation = MKPointAnnotation()
                        annotation.title = "\(stockInfo.city): \(stockInfo.stock) Pieces"
                        annotation.coordinate = CLLocationCoordinate2D(latitude: stockInfo.latitude, longitude: stockInfo.longitude)
                        self.mapView.addAnnotation(annotation)
                    }
                }
                if allStocksAreZero {
                    Router.makeAlert(titleInput: "Sorry :(", messageInput: "All stocks are empty.", viewController: self)
                } else {
                    let center = CLLocationCoordinate2D(latitude: 39.9334, longitude: 32.8597)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0))
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
}
