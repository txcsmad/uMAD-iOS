import Foundation
import MapKit
import CoreLocation

class AboutTableHeaderView: UIView {
    @IBOutlet var eventAbout: UILabel!
    @IBOutlet var organizationAbout: UILabel!
    @IBOutlet var organizationImage: UIImageView!
    @IBOutlet var eventMap: MKMapView!
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
                var locationAnnotation = MKPointAnnotation()
                locationAnnotation.coordinate = eventLocation!
                locationAnnotation.title = eventLocationName
                eventMap.addAnnotation(locationAnnotation)
                eventMap.selectAnnotation(locationAnnotation, animated: true)
            }

        } else {
            eventMap.hidden = true
        }

    }

}