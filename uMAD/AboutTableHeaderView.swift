import Foundation
import MapKit
import CoreLocation

class AboutTableHeaderView: UITableViewCell {
    @IBOutlet var eventAbout: UILabel!
    @IBOutlet var organizationAbout: UILabel!
    @IBOutlet var organizationImage: UIImageView!
    @IBOutlet var eventMap: MKMapView!
    @IBOutlet var mapTapRecognizer: UITapGestureRecognizer!
    var eventLocation: CLLocationCoordinate2D?
    var eventLocationName: String?
    override func awakeFromNib() {
        layoutSubviews()
    }
    func configure(){
        if eventLocation != nil {
            eventMap.hidden = false
            let viewRegion = MKCoordinateRegionMakeWithDistance(eventLocation!, 500, 500)
            let adjustedRegion = eventMap.regionThatFits(viewRegion)
            eventMap.setRegion(adjustedRegion, animated: false)
            eventMap.scrollEnabled = false
            eventMap.zoomEnabled = false

            if eventLocationName != nil {
                let locationAnnotation = MKPointAnnotation()
                locationAnnotation.coordinate = eventLocation!
                locationAnnotation.title = eventLocationName
                eventMap.addAnnotation(locationAnnotation)
                eventMap.selectAnnotation(locationAnnotation, animated: true)
            }

        } else {
            eventMap.hidden = true
        }

    }

    @IBAction func mapWasTapped(){

        let alertController = UIAlertController(title: "Need directions?", message:
            "We'll send you to Maps", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default){ (action) in
            self.openDirections()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel,handler: nil))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }

    func openDirections(){

            let placemark = MKPlacemark(coordinate: eventLocation!, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            if eventLocationName != nil {
                mapItem.name = eventLocationName
            }

            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            // Get the "Current User Location" MKMapItem
            let currentLocationMapItem = MKMapItem.mapItemForCurrentLocation()

            PFAnalytics.trackEventInBackground("openedDirections", dimensions:nil, block: nil)
            // Pass the current location and destination map items to the Maps app
            // Set the direction mode in the launchOptions dictionary
            MKMapItem.openMapsWithItems([currentLocationMapItem, mapItem],
                launchOptions:launchOptions)
    }

}