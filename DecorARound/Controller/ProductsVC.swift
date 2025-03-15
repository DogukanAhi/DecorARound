import UIKit

class ProductsVC: UIViewController {
    var category: Category?
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    private var cellSize: CGSize!
    private var screenSize = UIScreen.main.bounds
    private let product = [Product]()
    
    fileprivate  func prepareCellSize() {
        let width = ((screenSize.width-32)/2) * 0.9
        let height = width * 1.4
        cellSize = CGSize(width: width, height: height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCellSize()
        productCollectionView.dataSource = self
        productCollectionView.delegate = self
    }
}

extension ProductsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductsCell
        cell.priceLbl.text = "1 dolar"
        cell.productNameLbl.text = "Product Name"
        cell.imageView.image = UIImage(named: "koltuk")
        return cell
    }
    
}
extension ProductsVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("section: \(indexPath.section), item: \(indexPath.item)")
    }
}
extension ProductsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
