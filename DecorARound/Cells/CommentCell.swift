
import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var userMailLbl: UILabel!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

}
