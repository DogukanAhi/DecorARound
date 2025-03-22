import UIKit
import FirebaseAuth
import FirebaseFirestore
class CommentVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var productId: String = ""
    var comments: [CommentModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.fetchComennts()

    }
    
    private func fetchComennts() {
        let db = Firestore.firestore()
        db.collection("Comments")
            .document(productId)
            .collection("userComments")
            .order(by: "date", descending: true)
            .getDocuments() { snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }

                self.comments = snapshot?.documents.compactMap { doc -> CommentModel? in
                    let data = doc.data()
                    guard let userEmail = data["userEmail"] as? String,
                          let rating = data["rating"] as? Double,
                          let commentText = data["commentText"] as? String,
                          let timestamp = data["date"] as? Timestamp else { return nil }
                    return CommentModel(
                        userEmail: userEmail,
                        rating: rating,
                        commentText: commentText,
                        date: timestamp.dateValue()
                    )
                } ?? []

                // 🛑 reloadData burada çağrılmalı!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }

}

extension CommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell",for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        cell.commentLbl.text = comment.commentText
        cell.ratingBtn.setTitle("\(comment.rating)", for: .normal)
        switch comment.rating {
        case 0.0..<1.0:
            cell.ratingBtn.tintColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0) // Koyu kırmızı
        case 1.0..<2.0:
            cell.ratingBtn.tintColor = UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0) // Turuncumsu kırmızı
        case 2.0..<3.0:
            cell.ratingBtn.tintColor = UIColor(red: 0.9, green: 0.8, blue: 0.0, alpha: 1.0) // Sarımsı
        case 3.0..<4.0:
            cell.ratingBtn.tintColor = UIColor(red: 0.4, green: 0.8, blue: 0.0, alpha: 1.0) // Açık yeşil
        case 4.0..<5.1:
            cell.ratingBtn.tintColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0) // Koyu yeşil
        default:
            cell.ratingBtn.backgroundColor = UIColor.lightGray // Varsayılan renk
        }
        cell.userMailLbl.text = comment.userEmail
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: comment.date)
        cell.dateLbl.text = formattedDate
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
