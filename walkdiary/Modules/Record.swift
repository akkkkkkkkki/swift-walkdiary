import Foundation

class Record {
    var date: String
    var time: String
    var content: String
    var weather: String?
    var emotion: String?
    let uuid: String
    
    var description: String {
        return "date: \(date); time: \(time); content: \(content); weather: \(String(describing: weather)); emotion: \(String(describing: emotion))"
    }
    
    init(uuid: String, date: String, time: String, content: String) {
        self.date = date
        self.time = time
        self.content = content
        self.uuid = uuid
    }
    init(uuid: String, date: String, time: String, content: String, weather: String) {
        self.date = date
        self.time = time
        self.content = content
        self.weather = weather
        self.uuid = uuid
    }
    init(uuid: String, date: String, time: String, content: String, emotion: String) {
        self.date = date
        self.time = time
        self.content = content
        self.emotion = emotion
        self.uuid = uuid
    }
    init(uuid: String, date: String, time: String, content: String, weather: String, emotion: String) {
        self.date = date
        self.time = time
        self.content = content
        self.weather = weather
        self.emotion = emotion
        self.uuid = uuid
    }
    
    func getUuid() -> String {
        return self.uuid
    }
    
    func getWordCnt() -> Int {
        return content.count
    }
    
}

enum Weather {
    case sunny
    case cloudy  // 多云
    case overcast // 阴天
    case spinkle // 小雨
    case pour // 大雨
    case foggy
    case snowy
}

enum Emotion {
    case happy
    case yummy
    case mousy
    case eye
    case anxious
    case speechless
    case emo
}
