import Foundation
import UIKit

class BaiduNavViewController: UIViewController {
    
    var Begin_longitude:Double=0.0  //初始点X
    var Begin_latitude:Double=0.0   //初始点Y
    
    private var  longitude=CLLocationDegrees()  //初始点经度
    private var latitude=CLLocationDegrees()     //初始点纬度
    
    var navigator = BMKNavigation()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        longitude = Begin_longitude   //起点经度
        latitude =  Begin_latitude    //起点纬度
        
        let para = BMKNaviPara()
        para.endPoint = BMKPlanNode()
        para.endPoint.pt = CLLocationCoordinate2D(latitude: 39, longitude: 112)
        
        BMKNavigation.openBaiduMapWalk(para)

    }
    
}
