
struct CategoryService {
    func fetchCategories() -> [Category] {
        return [
            Category(title: "Living Room", image: "livingroom"),
            Category(title: "Bedroom", image: "bedroom"),
            Category(title: "Kitchen", image: "kitchen"),
            Category(title: "Office", image: "office"),
            Category(title: "Bathroom", image: "bathroom"),
            Category(title: "Garden", image: "garden"),
            Category(title: "Dining Room", image: "diningroom"),
            Category(title: "Kids Room", image: "kidsroom"),
            Category(title: "Outdoor", image: "outdoor"),
            Category(title: "Garage", image: "garage"),
            Category(title: "Hallway", image: "hallway")
        ]
    }
}
