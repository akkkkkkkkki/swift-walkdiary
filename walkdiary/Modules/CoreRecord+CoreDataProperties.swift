import Foundation
import CoreData


extension CoreRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreRecord> {
        return NSFetchRequest<CoreRecord>(entityName: "CoreRecord")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var emotion: String?
    @NSManaged public var time: String?
    @NSManaged public var uuid: String?
    @NSManaged public var weather: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var user: CoreUser?

}
