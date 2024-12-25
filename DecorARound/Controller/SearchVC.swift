import UIKit

class SearchVC: UIViewController {
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    private var data: [Category] = []
    private let categoryService = CategoryService()
    private var selectedCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        self.fetchData()
        
    }

    private func fetchData() {
        data = categoryService.fetchCategories()
        categoryTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toProductsVC",
               let destinationVC = segue.destination as? ProductsVC,
               let category = selectedCategory {
                destinationVC.category = category
            }
        }
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.categoryImage.image = UIImage(named: category.image ?? "")
        cell.categoryLabel.text = category.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = data[indexPath.row]
        self.performSegue(withIdentifier: "toProductsVC", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.white

            let titleLabel = UILabel()
            titleLabel.text = "Categories"
        titleLabel.textColor = UIColor.systemBlue
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            headerView.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 1),
            ])

            return headerView
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 50 // Özelleştirilmiş başlık yüksekliği
        }
}
