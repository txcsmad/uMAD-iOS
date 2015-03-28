import Foundation

protocol CompanyDelegate {
    func didGetData()
}

class Company: NSObject {
    let name: String
    let sponsorLevel: Int
    let website: NSURL
    let twitterHandle: String
    let objectID: String
    var image: UIImage?
    var thumbnail: UIImage?
    var delegate: CompanyDelegate?

    init(parseReturn: PFObject) {
        name = parseReturn["name"] as! String
        twitterHandle = parseReturn["twitterHandle"] as! String
        website = NSURL(string: parseReturn["website"] as! String)!
        sponsorLevel = parseReturn["sponsorLevel"] as! Int
        objectID = parseReturn.objectId

        super.init()
        let imageFile = parseReturn["image"] as! PFFile
        imageFile.getDataInBackgroundWithBlock({
            (data: NSData!, error: NSError!) -> Void in
                self.image = UIImage(data: data)!
            self.delegate?.didGetData()

        })
        let thumbnailFile = parseReturn["thumbnail"] as! PFFile
        thumbnailFile.getDataInBackgroundWithBlock({
            (data: NSData!, error: NSError!) -> Void in
            self.thumbnail = UIImage(data: data)!
            self.delegate?.didGetData()
        })

    }


   func stringDescription() -> String {
        return "\(name)"
    }

}