struct User {

    let id: String
    let name: String
    let screenName: String
    let profileImageUrl: NSURL

    private init(json: NSDictionary) {
        id = json["id_str"] as! String
        name = json["name"] as! String
        screenName = json["screen_name"] as! String

        let profileImageUrlString = json["profile_image_url_https"] as! String
        let biggerProfileImageUrlString = profileImageUrlString.stringByReplacingOccurrencesOfString("normal", withString: "bigger", options: .LiteralSearch, range: nil)
        profileImageUrl = NSURL(string: biggerProfileImageUrlString)!
    }

    static func getUser(json: NSDictionary) -> User {
        let cached = TimelineManager.instance.users[json["name"] as! String]
        if cached != nil {
            return cached!
        }
        else {
            return User(json: json)
        }
    }
    
}