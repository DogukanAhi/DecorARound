import UIKit

class PastOrdersImagesCell: UICollectionViewCell {
    @IBOutlet weak var pastOrdersImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        pastOrdersImageView.clipsToBounds = true
    }
}
