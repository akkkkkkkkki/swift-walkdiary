import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate, BMKLocationAuthDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            // 要使用百度地图，请先启动BMKMapManager
            let mapManager = BMKMapManager()
            // 启动引擎并设置AK并设置delegate
            if !(mapManager.start("p7SWXTc8H3MT6z7O2GFz0GCuVuwzGXfG", generalDelegate: self)) {
                NSLog("启动引擎失败")
            }
        // 地图隐私声明
        BMKMapManager.setAgreePrivacy(true)
        // 定位隐私声明
        let auth = BMKLocationAuth()
        auth.checkPermision(withKey:"p7SWXTc8H3MT6z7O2GFz0GCuVuwzGXfG" , authDelegate: self)
        auth.setAgreePrivacy(true)
        
        // 导航隐私声明
//        BNaviService.setAgreePrivacy(true)
        
            return true
        }
    
    
    // MARK: - BMKGeneralDelegate

    func onGetNetworkState(_ iError: Int32) {
        if iError == 0 {
            print("联网成功")
        } else {
            print("onGetNetworkState \(iError)")
        }
    }

    func onGetPermissionState(_ iError: Int32) {
        if iError == 0 {
            print("授权成功")
        } else {
            print("onGetPermissionState \(iError)")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    weak var popupViewDelegate: MyviewDelegate?

//    func dismissEditViewWithCoordinate(coordinate: CLLocationCoordinate2D, record: Record) {
//        popupViewDelegate?.didDismissWithCoordinate(coordinate: coordinate, record: record, nsrecord: CoreRecord)
//        // 在这里处理 dismiss 编辑视图的逻辑
//    }
//
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "walkdiary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // 其他 AppDelegate 方法...

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 保存 Core Data 中的更改（如果有的话）
        saveContext()
    }


}

protocol MyviewDelegate: AnyObject {
    func didDismissWithCoordinate(coordinate: CLLocationCoordinate2D, record: Record, nsrecord: CoreRecord)
    func didDismissAlone()
    func didDeleteRecord(id: String)
    func didPostSearch(searchResults: [Restaurant], distance: Int)
}
