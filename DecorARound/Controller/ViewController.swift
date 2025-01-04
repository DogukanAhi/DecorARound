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
        if let layout = campaignCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        campaignCollectionView.showsHorizontalScrollIndicator = false
        campaignCollectionView.decelerationRate = .fast
        campaignCollectionView.isPagingEnabled = true
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
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        for cell in campaignCollectionView.visibleCells {
            if let campaignCell = cell as? CampaignCell {
                campaignCell.pageControl.numberOfPages = campaignImages.count
                campaignCell.pageControl.currentPage = Int(pageIndex)
            }
        }
    }
}
