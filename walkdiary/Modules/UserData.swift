import Foundation

class UserData {
    var records: [String: Record]
    var username: String
    var registerDate: String
    var uuid: String
    
    init(uuid: String, username: String, registerDate: String) {
        self.records = [:]
        self.username = username
        self.registerDate = registerDate
        self.uuid = uuid
    }
    
    func getRecord(id: String) -> Record {
        return records[id] ?? Record(uuid: " ", date: "yyyy mm dd", time: "hh: mm", content: "default")
    }
    
    func addRecord(id: String, record: Record) {
        records[id] = record
    }
    
    func removeRecord(id: String) {
        self.records.removeValue(forKey: id)
    }
    
    func getRegisteredDate() -> Int {  // 个人中心的标题显示的已注册天数
        let formatter = DateFormatter()
        let calender = Calendar.current
        formatter.dateFormat = "yyyy mm dd"
        
        _ = Date()
        let start = formatter.date(from: registerDate)
        let end = formatter.date(from: formatter.string(from: Date()))
        
        let diff: DateComponents = calender.dateComponents([.day], from: start!, to: end!)
        return diff.day!
    }
    
    func getRecordCnt() -> Int {
        return records.count
    }
    
    func getRecordWordCnt() -> Int {
        var ret = 0
        for record in records.values {
            ret += record.getWordCnt()
        }
        return ret
    }
}
