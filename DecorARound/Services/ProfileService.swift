
struct ProfileService {
    func fetchProfiles() -> [Profile] {
        return [
            Profile(title: "User Info", image: "person.fill"),
            Profile(title: "Favorites", image: "heart.fill"),
            Profile(title: "Past Orders", image: "basket.fill"),
            Profile(title: "Logout", image: "person.crop.circle.badge.xmark")
        ]
    }
}
