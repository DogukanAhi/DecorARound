

import UIKit

class ProductDetailCell: UICollectionViewCell {
    
   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    func configure(imageUrl: String, currentPage: Int, totalPages: Int) {
            // 📌 Kingfisher kullanarak URL'den görüntüyü yükle
            if let url = URL(string: imageUrl) {
                imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
            } else {
                imageView.image = UIImage(systemName: "photo")
            }

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
