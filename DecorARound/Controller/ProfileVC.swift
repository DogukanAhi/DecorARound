import UIKit
import FirebaseAuth
class ProfileVC: UIViewController {
    
    private var data: [Profile] = []
    private let profileService = ProfileService()
    let currentUser = Auth.auth().currentUser?.email ?? "Welcome! Sign Up"
    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        self.fetchData()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 50, width: view.frame.width, height: 44))
        view.addSubview(navigationBar)
        let navigationItem = UINavigationItem(title: currentUser)
        let leftButton = UIBarButtonItem(
            image: UIImage(systemName: "envelope.fill"),
            style: .plain,
            target: self,
            action: nil
        )
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "bell.fill"),
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationBar.items = [navigationItem]
    }
    
    func fetchData() {
        data = profileService.fetchProfiles()
        profileTableView.reloadData()
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profile = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell
        cell.iconView.image = UIImage(systemName:profile.image ?? "")
        cell.titleLbl.text = profile.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
