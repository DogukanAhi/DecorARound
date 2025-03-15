import UIKit

class ProductDetailVC: UIViewController {
    
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var qtyButton: UIButton!
    @IBOutlet weak var stepperBtn: UIStepper!
    @IBOutlet weak var arButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    var productDetails: [String: Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let details = productDetails {
            titleLbl.text = details["name"] as? String ?? "Unknown Product"
            detailLbl.text = details["description"] as? String ?? "No Description Available"
            priceLabel.text = String(format: "$%.2f", details["price"] as? Double ?? 0.0)
            let rating = details["rating"] as? Double ?? 0.0
            rateButton.setTitle("\(rating)", for: .normal)
            updateRatingButtonColor(rating: rating)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toStockVC",
               let stockVC = segue.destination as? StockVC {
                stockVC.productStock = productDetails?["stock"] as? [String: Int] ?? [:] // 📌 Stok bilgilerini gönder
            }
        }
    private func updateRatingButtonColor(rating: Double) {
        switch rating {
        case 0.0..<1.0:
            rateButton.tintColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0) // Koyu kırmızı
        case 1.0..<2.0:
            rateButton.tintColor = UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0) // Turuncumsu kırmızı
        case 2.0..<3.0:
            rateButton.tintColor = UIColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 1.0) // Sarımsı
        case 3.0..<4.0:
            rateButton.tintColor = UIColor(red: 0.4, green: 0.8, blue: 0.0, alpha: 1.0) // Açık yeşil
        case 4.0...5.0:
            rateButton.tintColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0) // Koyu yeşil
                
        default:
            rateButton.backgroundColor = UIColor.lightGray // Varsayılan renk
        }
    }
    
    @IBAction func addToCardClicked(_ sender: Any) {
        Router.makeAlert(titleInput: "Added", messageInput: "Product Successfully Added to Cart", viewController: self)
    }
    
    @IBAction func stepperClicked(_ sender: UIStepper) {
        qtyButton.setTitle("\(Int(sender.value))", for: .normal)
    }
    
    @IBAction func stockButtonClicked(_ sender: Any) {
        print("stockBtn Called")
        self.performSegue(withIdentifier: "toStockVC", sender: nil)
    }
    
    @IBAction func arButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
               
               // 📌 ARViewController'ı tanımla (Storyboard ID "ARViewController" olacak)
               if let arVC = storyboard.instantiateViewController(withIdentifier: "ArVC") as? ArVC {
                   
                   // 🎯 ARVC'yi modally aç (Eğer bir Navigation Controller içindeyse push da yapılabilir)
                   arVC.modalPresentationStyle = .fullScreen
                   self.present(arVC, animated: true, completion: nil)
               }
    }
    @IBAction func favoriteButtonClicked(_ sender: Any) {
        Router.makeAlert(titleInput: "Favorite", messageInput: "Product Added to Favorite", viewController: self)
    }
}
