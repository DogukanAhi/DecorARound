
import UIKit

class ProductsVC: UIViewController {
    var category: Category?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let category = category {
            print(category.title)
        }
            
            
    }
    
}
