import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var campaignCollectionView: UICollectionView!
    
    var campaignImages: [UIImage] = [
        UIImage(named: "campaign2")!,
        UIImage(named: "campaign2")!,
        UIImage(named: "campaign2")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        campaignCollectionView.delegate = self
        campaignCollectionView.dataSource = self
        
        // Sadece yatay kaydırmayı etkinleştirin
        if let layout = campaignCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0 // Hücreler arasında boşluk bırakma
        }
        
        campaignCollectionView.showsHorizontalScrollIndicator = false // Kaydırma çubuğunu gizle
        
        // Daha yumuşak kaydırma için decelerationRate ayarı
        campaignCollectionView.decelerationRate = .fast
        
        // Collection view yeniden yüklendiğinde page control'ün güncellenmesi
        campaignCollectionView.isPagingEnabled = true // Hücreleri tam sayfa yaparak kaydırma sağla
        campaignCollectionView.reloadData()
    }
    
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        let indexPath = IndexPath(item: page, section: 0)
        campaignCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func arButtonClicked(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toArVC", sender: nil)
    }
    
    
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return campaignImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CampaignCell", for: indexPath) as! CampaignCell
        cell.configure(image: campaignImages[indexPath.row], currentPage: indexPath.row, totalPages: campaignImages.count)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Hücre boyutunu, collection view'in genişliği ve yüksekliğine tam olarak uyumlu yap
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Hücreler arasındaki boşluğu sıfırla
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Sayfayı doğru hesaplamak için pageControl'ü güncelleyin
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        
        // CampaignCell'lerin her birinde pageControl'ü güncelleyin
        for cell in campaignCollectionView.visibleCells {
            if let campaignCell = cell as? CampaignCell {
                campaignCell.pageControl.numberOfPages = campaignImages.count
                campaignCell.pageControl.currentPage = Int(pageIndex)
            }
        }
    }
}
