import UIKit
class CampaignCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!

    func configure(image: UIImage, currentPage: Int, totalPages: Int) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit // Görselleri hücreye sığdır
        pageControl.numberOfPages = totalPages
        pageControl.currentPage = currentPage
        pageControl.isUserInteractionEnabled = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.clipsToBounds = true // Görsellerin taşmasını engelle
    }
}
