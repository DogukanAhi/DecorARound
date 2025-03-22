import UIKit

class CheckoutCell: UICollectionViewCell {
    var onStepperChange: ((Int) -> Void)?
    var onDeleteTapped: (() -> Void)?
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var strepper: UIStepper!
    @IBOutlet weak var qtyLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func strepperChanged(_ sender: UIStepper){
        let newQty = Int(sender.value)
            qtyLbl.text = "\(newQty)"
            onStepperChange?(newQty)    }
    
    @IBAction func deleteBtnClicked(_ sender: Any) {
        onDeleteTapped?()
    }
}
