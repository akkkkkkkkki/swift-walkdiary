import Foundation
import CoreData


extension CoreUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreUser> {
        return NSFetchRequest<CoreUser>(entityName: "CoreUser")
    }

    @NSManaged public var registerDate: String?
    @NSManaged public var username: String?
    @NSManaged public var uuid: String?
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for records
extension CoreUser {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: CoreRecord)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: CoreRecord)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}
