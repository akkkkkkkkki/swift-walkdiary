import Foundation

class UserManager {
    static let manager = UserManager()
    var users: [String: UserData]
//    var user: UserData
    var isLog = true
    
    private init() {
        self.users = [:]
    }
    
    
}


