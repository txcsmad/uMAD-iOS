import Foundation

class EventReference: NSObject {
    weak var referenced: Event?
    init(event: Event){
        referenced = event
    }
}