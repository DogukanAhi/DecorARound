
struct CategoryService {
    func fetchCategories() -> [Category] {
        return [
            Category(title: "Living Room", image: "livingroom"),
            Category(title: "Bedroom", image: "bedroom"),
            Category(title: "Kitchen", image: "kitchen"),
            Category(title: "Office", image: "office")
        ]
    }
}
