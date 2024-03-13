import Foundation
import CoreData


var recordCnt: Int = 0
var userCnt: Int = 0

let userPrefix = "@user"
let recordPrefix = "%rcd"
let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

func genRecordUuid() -> String {
    recordCnt += 1
    let curTime = Date()
    print(curTime)
    return recordPrefix + "\(curTime)" + "\(recordCnt)"
}

func genUuid() -> String {
    userCnt += 1
    return userPrefix + "\(userCnt)"
}

func getRecordCnt()->Int {
    let userFetchRequest: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "uuid == %@", coreRootUser.uuid!) // 2
    do {
        let users = try managedContext?.fetch(userFetchRequest)
        if let user = users?.first {
            if let records = user.records as? Set<CoreRecord> {
                return records.count
            }
        }
    } catch {
        print("Failed to add user records: \(error)")
    }
    return 0
}

func getWordCnt() -> Int {
    var ret = 0
    let userFetchRequest: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "uuid == %@", coreRootUser.uuid!) // 2
    do {
        let users = try managedContext?.fetch(userFetchRequest)
        if let user = users?.first {
            // 接下来可以遍历用户的records，添加
            if let records = user.records as? Set<CoreRecord> {
                for record in records {
                    ret += record.content?.count ?? 0
                }
            }
        }
    } catch {
        print("Failed to add user records: \(error)")
    }
    return ret
}
