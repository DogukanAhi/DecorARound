import UIKit
import FirebaseAuth
class ProfileVC: UIViewController {
    
    private var data: [Profile] = []
    private let profileService = ProfileService()
    var currentUser = Auth.auth().currentUser?.email ?? "Welcome! Sign Up"
    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        self.fetchData()
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoginVC()
    }
    
    private func showLoginVC() {
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "toLoginVC", sender: nil)
            
        }
        
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
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
    }
    
    func fetchData() {
        data = profileService.fetchProfiles()
        profileTableView.reloadData()
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return data.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Auth.auth().currentUser != nil {
            let profile = data[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell
            cell.iconView.image = UIImage(systemName:profile.image ?? "")
            cell.titleLbl.text = profile.title
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell
            cell.titleLbl.text = "Login"
            cell.textLabel?.textColor = .systemBlue
            cell.iconView.image = UIImage(systemName: "person.circle")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if Auth.auth().currentUser == nil {
                self.performSegue(withIdentifier: "toLoginVC", sender: nil)
            } else {
                print("doğru")
                self.performSegue(withIdentifier: "toUserInfoVC", sender: nil)
            }
        case (0, 1):
            self.performSegue(withIdentifier: "toFavoriVC", sender: nil)
        case (0, 3):
            do {
                try Auth.auth().signOut()
                Router.makeAlert(titleInput: "You have successfully logged out!", messageInput: "", viewController: self)
                self.profileTableView.reloadData()
                self.currentUser = Auth.auth().currentUser?.email ?? "Welcome! Sign Up"
                self.setupNavigationBar()
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError)")
            }
        case (0,2):
            self.performSegue(withIdentifier: "toPastOrdersVC", sender: nil)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
