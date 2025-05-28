import UIKit
import MapKit
import CoreLocation

class StockVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    private let fetchService = FetchCoordinatesService()
    private let locationManager = CLLocationManager()
    var productStock: [String: Int] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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

                        let annotation = MKPointAnnotation()
                        annotation.title = "\(stockInfo.city): \(stockInfo.stock) Pieces"
                        annotation.coordinate = CLLocationCoordinate2D(latitude: stockInfo.latitude, longitude: stockInfo.longitude)
                        self.mapView.addAnnotation(annotation)
                    }
                }

                if allStocksAreZero {
                    Router.makeAlert(titleInput: "Sorry :(", messageInput: "All stocks are empty.", viewController: self)
                }
                // Konum kullanıcıdan alındığı için burada ekstra merkez ayarı yapmaya gerek yok
            }
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last else { return }

        let region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )
        mapView.setRegion(region, animated: true)

        // Konum bir kez alındıktan sonra güncellemeyi durdur
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
    }
}
