import UIKit
class PastOrdersCell: UITableViewCell {
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!

    var productImages: [String] = []
    var onRateTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.reloadData()
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
    }

    @IBAction func rateBtnClicked(_ sender: Any) {
        onRateTapped?()
    }
}

extension PastOrdersCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastOrdersImagesCell", for: indexPath) as? PastOrdersImagesCell else {
            return UICollectionViewCell()
        }

        let url = URL(string: productImages[indexPath.row])
        cell.pastOrdersImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
        cell.pastOrdersImageView.contentMode = .scaleAspectFit
        cell.pastOrdersImageView.clipsToBounds = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
}
