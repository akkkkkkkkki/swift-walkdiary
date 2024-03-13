import UIKit
import CoreData

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let rootUser = UserData(uuid: "3", username: "cathy", registerDate: "2023 11 20") // 暂时
var coreRootUser = CoreUser.init()

extension UIColor {
    convenience init(hex: Int) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension CAGradientLayer {
    func createGradientImage() -> UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}

extension BMKAnnotationView {
    func addAnimation1() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.8
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.5
        self.layer.add(scaleAnimation, forKey: "scale-layer")
    }
    
    func removeAnimation1() {
        self.layer.removeAllAnimations()
    }
}

var pawViews: [String: BMKMyAnnotationView] = [:]


class ViewController: UIViewController, BMKMapViewDelegate, MyviewDelegate, BMKLocationManagerDelegate, UIScrollViewDelegate {
    let locationManager = LocationService()
    var completionBlock: BMKLocatingCompletionBlock?
    
    var addButton = UIButton()
    var searchBtn = UIButton()
    var locationBtn = UIButton()
    var navigationBtn = UIButton()
    
    
    var annotation = BMKPointAnnotation.init()  // 这个仅仅是当前长按的地方会显示，当submit之后会对每个record新建标记物
    
    let centerView = CenterViewController()
    var editView = PopupViewController()
    let searchView = POISearchViewController()
    
    let topBtnSize = 60
    let topBtnX = 40
    let topBtnminY = 80
    
    var pawId = " "
    
    var mapView: BMKMapView?
    
    // 展示搜索结果相关
    let resultView = UIScrollView()
    var searchResults: [Restaurant] = []
    let location = POI()
    
    static var first = true
    
   override func viewDidLoad() {
       // 创建或者获取NSManagedObjectContext
       guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
       }
       let managedContext = appDelegate.persistentContainer.viewContext
//       coreRootUser = NSEntityDescription.insertNewObject(forEntityName: "CoreUser",
//                                                              into: managedContext) as! CoreUser
//       coreRootUser.uuid = rootUser.uuid
//       coreRootUser.username = "Cathy"
//       coreRootUser.registerDate = "2023 11 20"
       
       
       super.viewDidLoad()
       mapView = BMKMapView(frame: self.view.frame)
       mapView?.delegate = self
       self.view.addSubview(mapView!);
//           mapView?.show(BMKMapParticleEffectSnow)  粒子效果，超级卡
       
       let centerBtn = UIButton(frame: CGRect(x: topBtnX, y: topBtnminY, width: topBtnSize, height: topBtnSize))
       centerBtn.setImage(UIImage(named: "user"), for: .normal)
       centerBtn.addTarget(self, action: #selector(showCenter), for: .touchUpInside)
       view.addSubview(centerBtn)
       
       let shareBtn = UIButton(frame: CGRect(x: Int(screenWidth) - topBtnX - 50, y: topBtnminY, width: topBtnSize, height: topBtnSize))
       shareBtn.setImage(UIImage(named: "share"), for: .normal)
       shareBtn.addTarget(self, action: #selector(refresh), for: .touchUpInside)
       view.addSubview(shareBtn)
       
        locationBtn = UIButton(frame: CGRect(x: Int(screenWidth) - topBtnX - 50, y: Int(screenHeight) - topBtnminY - 50, width: topBtnSize, height: topBtnSize))
       locationBtn.setImage(UIImage(named: "location2"), for: .normal)
       locationBtn.addTarget(self, action: #selector(startLocationService), for: .touchUpInside)
       view.addSubview(locationBtn)
       
       navigationBtn = UIButton(frame: CGRect(x: Int(screenWidth) - topBtnX - 50, y: Int(screenHeight) - topBtnminY - 50, width: topBtnSize, height: topBtnSize))
       navigationBtn.setImage(UIImage(named: "navigation"), for: .normal)
       navigationBtn.addTarget(self, action: #selector(startNavigation), for: .touchUpInside)
       
//           annotation.coordinate = CLLocationCoordinate2D(latitude: 39.915, longitude: 116.404)
       
       mapView?.showsUserLocation = false
       mapView?.userTrackingMode = BMKUserTrackingModeHeading
       mapView?.showsUserLocation = true
       
       resultView.frame = CGRect(x: 50, y: screenHeight / 2 + 100, width: screenWidth - 100, height: 200)
       resultView.isPagingEnabled = true
       resultView.delegate = self
       
       let userFetchRequest: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
       userFetchRequest.predicate = NSPredicate(format: "uuid == %@", rootUser.uuid) // 2
       do {
           let users = try managedContext.fetch(userFetchRequest)
           coreRootUser = users.first ?? coreRootUser
       } catch {
           print("Failed to find user: \(error)")
       }
       
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView?.viewWillAppear()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView?.viewWillDisappear()
        mapView?.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func mapViewDidFinishRendering(_ mapView: BMKMapView) {
        // 查询当前用户的所有record并添加
    }
    
    // 长按地图
    func mapview(_ mapView: BMKMapView, onLongClick coordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotation(annotation)
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        showAddSearchBtn()
    }
    
    
    func showAddSearchBtn() {
        // 调整btn的初始状态，设置透明度为0实现动画效果
        addButton.alpha = 0.0
        searchBtn.alpha = 0.0
        self.view.addSubview(locationBtn)
        mapView?.removeAnnotation(location)
        navigationBtn.removeFromSuperview()
        resultView.removeFromSuperview()
        
        let btnWidth: CGFloat = 60
        let btnHeight: CGFloat = 60
        addButton.frame = CGRect(x: (view.bounds.width)/2  - btnWidth, y: (view.bounds.height - btnHeight - 80), width: btnWidth, height: btnHeight)
        addButton.layer.cornerRadius = btnHeight / 2
        addButton.layer.masksToBounds = true
        addButton.backgroundColor = UIColor.white
        
        searchBtn.frame = CGRect(x: (view.bounds.width)/2, y: (view.bounds.height - btnHeight - 80), width: btnWidth, height: btnHeight)
        searchBtn.layer.cornerRadius = btnHeight / 2
        searchBtn.layer.masksToBounds = true
        searchBtn.backgroundColor = UIColor(named: "mid")
        
        var locaStr = "record"
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        addButton.setTitleColor(UIColor.black, for: .normal)
        addButton.setTitle(locaStr, for: .normal)
        
        locaStr = "search"
        searchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        searchBtn.setTitleColor(UIColor.black, for: .normal)
        searchBtn.setTitle(locaStr, for: .normal)
        
        // 动画形式显示按钮
        view.addSubview(addButton)
        view.addSubview(searchBtn)
        mapView?.addSubview(addButton)
        UIView.animate(withDuration: 0.3) {
            self.addButton.alpha = 1.0
            self.searchBtn.alpha = 1.0
        }
        
        
        // 按钮连接显示编辑框的函数
        addButton.addTarget(self, action: #selector(showEdit), for: .touchUpInside)
        searchBtn.addTarget(self, action: #selector(showSearch), for: .touchUpInside)
    }
    
    // add annotation 自动调用的函数
    func mapView(_ mapView: BMKMapView, viewFor annotation: BMKAnnotation) -> BMKAnnotationView? {
        if annotation.isKind(of: Paw.self) {
            var annotationView: BMKMyAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pawId) as? BMKMyAnnotationView
            if annotationView == nil {
                annotationView = BMKMyAnnotationView.init(annotation: annotation, reuseIdentifier: pawId)
            }
            annotationView!.isDraggable = false
            annotationView?.canShowCallout = false
            annotationView?.annotation = annotation
            annotationView?.image = UIImage.init(named: "paw")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
            annotationView?.addAnimation()
            annotationView?.id = pawId
            
            pawViews[pawId] = annotationView
            
            return annotationView
        } else if annotation.isKind(of: POI.self) {
            var annotationView: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationViewIdentifier") as? BMKPinAnnotationView
            if annotationView == nil {
                annotationView = BMKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "annotationViewIdentifier")
            }
//            annotationView!.animatesDrop = true
            // 设置是否可以拖拽
            annotationView!.isDraggable = false
            annotationView?.canShowCallout = true
            annotationView?.annotation = annotation
            annotationView?.image = UIImage.init(named: "pin2")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
//            annotationView?.addAnimation1()  不添加动画
            
            
            return annotationView
        } else if annotation.isKind(of: BMKPointAnnotation.self) {
            /**
             根据指定标识查找一个可被复用的标注，用此方法来代替新创建一个标注，返回可被复用的标注
             */
            var annotationView: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationViewIdentifier") as? BMKPinAnnotationView
            if annotationView == nil {
                annotationView = BMKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "annotationViewIdentifier")
            }
            annotationView!.animatesDrop = true
            // 设置是否可以拖拽
            annotationView!.isDraggable = false
            annotationView?.canShowCallout = true
            annotationView?.annotation = annotation
            annotationView?.image = UIImage.init(named: "pin")
            annotationView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            annotationView?.addAnimation1()
            annotationView?.centerOffset = CGPoint(x: 0, y: -40) // 使得pin的最下端在长按位置
            
            
            return annotationView
        }
        return nil
    }
    
    // 显示编辑框
    @objc func showCenter() {
        centerView.refresh()
        centerView.modalPresentationStyle = .overCurrentContext // 设置弹出视图的方式
        present(centerView, animated: true, completion: nil)
        addButton.removeFromSuperview()
    }
    
    @objc func showEdit() { // 每次添加一个还是refresh？如何refresh？
        if (UserManager.manager.isLog) {
            // 设置居中
            mapView?.centerCoordinate = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude)
            
            
            editView = PopupViewController()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.popupViewDelegate = self
            editView.delegate = self
            editView.setCoordinate(coordinate: annotation.coordinate)
            editView.modalPresentationStyle = .overCurrentContext // 设置弹出视图的方式
            present(editView, animated: true, completion: nil)
        } else {
            let loginView = LogRegViewController()
            loginView.modalPresentationStyle = .overCurrentContext
            present(loginView, animated: true, completion: nil)
        }
        addButton.removeFromSuperview()

    }
    
    
  // 实现编辑框的代理
    func didDismissWithCoordinate(coordinate: CLLocationCoordinate2D, record: Record, nsrecord: CoreRecord) {
            // 在这里处理传递过来的坐标逻辑
        
        
        mapView?.removeAnnotation(annotation)
        let newPaw = Paw()
        newPaw.coordinate = coordinate
        
        pawId = record.uuid
        mapView?.addAnnotation(newPaw)
    }
    
    func didDismissAlone() {
        mapView?.removeAnnotation(annotation)
    }
    
    // 选中paw
    func mapView(_ mapView: BMKMapView, didSelect view: BMKAnnotationView) {
        if view.isKind(of: BMKMyAnnotationView.self) {
            annotation.coordinate = view.annotation.coordinate
            mapView.addAnnotation(annotation)
            
//            mapView.centerCoordinate = view.annotation.coordinate
            
            let newView = view as! BMKMyAnnotationView
            
            view.setSelected(false, animated: false)
            let recordView = RecordViewController()
            recordView.delegate = self
            
            recordView.modalPresentationStyle = .overCurrentContext
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let userFetchRequest: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "uuid == %@", coreRootUser.uuid!)
            do {
                let users = try managedContext.fetch(userFetchRequest)
                if let user = users.first {
                    // 找到了对应的User对象
                    // 接下来可以遍历用户的records，找到要删除的记录并删除它
                    if let records = user.records as? Set<CoreRecord> {
                        for record in records {
                            if record.uuid == newView.id {
                                recordView.coreRecord = record
                                break
                            }
                        }
                    }
                }
            } catch {
                print("Failed to find record: \(error)")
            }
            
            recordView.record = rootUser.getRecord(id: newView.id)
            present(recordView, animated: true)
        }
    }
    
    func didDeleteRecord(id: String) {
        mapView?.removeAnnotation(pawViews[id]!.annotation)
        rootUser.removeRecord(id: id)
    }
    
    @objc func startLocationService() {
        self.completionBlock = { (location: BMKLocation?, state: BMKLocationNetworkState, error: Error?) in
            if let error = error {
                print("LocError: {\(error._code) - \(error.localizedDescription)};")
            }
            
            if let location = location {
                if let loc = location.location {
                    print("Current location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
                    self.mapView?.setCenter(loc.coordinate, animated: true)
                    self.mapView?.removeAnnotation(self.annotation)
                    self.annotation.coordinate = loc.coordinate
                    self.mapView?.addAnnotation(self.annotation)
                }
                
                if let rgcData = location.rgcData {
                    print("ReGeocode info: \(rgcData)")
                    
                    if let poiList = rgcData.poiList {
                        for poi in poiList {
                            print("Poi: \(poi.name ?? ""), \(poi.addr ?? ""), \(poi.relaiability), \(poi.tags ?? ""), \(poi.uid ?? "")")
                        }
                    }
                    
                    if let poiRegion = rgcData.poiRegion {
                        print("PoiRegion: \(poiRegion.name ?? ""), \(poiRegion.tags ?? ""), \(poiRegion.directionDesc ?? "")")
                    }
                }
            }
        }
        
        locationManager.mapManager.requestLocation(withReGeocode: true, withNetworkState: true, completionBlock: self.completionBlock!)
        showAddSearchBtn()
        
    }
    
    func didUpdateBMKUserLocation(_ userLocation: BMKUserLocation) { // 连续定位需要的函数
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
        self.mapView?.setCenter(userLocation.location.coordinate, animated: true)
        mapView?.updateLocationData(userLocation)
    }
    
    @objc func showSearch() {
        searchView.delegate = self
        searchView.center = annotation.coordinate // poi搜索的中心点
        searchView.modalPresentationStyle = .overCurrentContext // 设置弹出视图的方式
        present(searchView, animated: true, completion: nil)
    }
    
    
    func didPostSearch(searchResults: [Restaurant], distance: Int) {
        self.searchBtn.removeFromSuperview()
        self.addButton.removeFromSuperview()
        
        // 地图放大
        var zoomLevel: Float = 14
        switch (distance) {
        case 500:
            zoomLevel = 15
        case 1000:
            zoomLevel = 14
        case 5000:
            zoomLevel = 13
        case 10000:
            zoomLevel = 12
        default:
            zoomLevel = 14
        }
        mapView?.zoomLevel = zoomLevel // 后期考虑传另一个参数也就是周围多少m来确定放大倍数
        mapView?.centerCoordinate = annotation.coordinate
        
        
        // scrollview复原
        resultView.contentOffset.y = 0
        
        // 隐藏location
        locationBtn.removeFromSuperview()
        // 显示导航btn
        self.view.addSubview(navigationBtn)
        
        
        self.view.addSubview(resultView)
        let cnt = searchResults.count
        resultView.contentSize = CGSize(width: 200 , height: 400 * cnt) // 要有这个才能滑动
        var index = 0
        self.searchResults = searchResults
        for restaurant in searchResults {
            let item = UIView(frame: CGRect(x: 0, y: 200*index, width: Int(screenWidth) - 100, height: 200))
            
            let name = UILabel(frame: CGRect(x: item.frame.minX + 20, y: item.frame.minY + 10, width: item.frame.width - 20, height: 40))
            name.text = restaurant.name
            let address = UILabel(frame: CGRect(x: item.frame.minX + 20, y: item.frame.minY + 23, width: item.frame.width - 20, height: 70))
            address.font = UIFont.systemFont(ofSize: 12)
            address.textColor = UIColor.gray
            address.text = restaurant.address
            let time = UILabel(frame: CGRect(x: item.frame.minX + 20, y: item.frame.minY + 50, width: item.frame.width, height: 70))
            time.font = UIFont.systemFont(ofSize: 15)
            time.text = "营业时间: " + restaurant.opening
            let price = UILabel(frame: CGRect(x: item.frame.minX + 20, y: item.frame.minY + 75, width: item.frame.width, height: 70))
            price.font = UIFont.systemFont(ofSize: 15)
            price.text = "\(restaurant.price)" + "/人" + "   \(restaurant.distance)m"
            let url = UILabel(frame: CGRect(x: item.frame.minX, y: item.frame.maxY - 100, width: item.frame.width, height: 70))
            url.font = UIFont.systemFont(ofSize: 12)
            url.text = restaurant.url
            
            
            
            let info = UILabel(frame: CGRect(x: item.frame.minX + 20, y: item.frame.maxY - 70, width: item.frame.width, height: 70))
            info.font = UIFont.systemFont(ofSize: 12)
            info.text = "评论 \(restaurant.commentNumber)  收藏:  \(restaurant.favoriteNumber)"
            let rating = UILabel(frame: CGRect(x: item.frame.maxX - 80, y: item.frame.maxY - 80, width: 100, height: 70))
            rating.font = UIFont.systemFont(ofSize: 25)
            rating.text = "\(restaurant.rating)" + "分"
            let locationBtn = UIButton(frame: CGRect(x: item.frame.minX + 150, y: item.frame.maxY - 70, width: 50, height: 50))
//            locationBtn.addTarget(self, action: #selector(setPoiLocation), for: .touchUpInside)
            locationBtn.tag = index
            locationBtn.setImage(UIImage(named: "location"), for: .normal)
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [UIColor(named: "light")?.cgColor ?? UIColor.black, UIColor(named: "mid")?.cgColor ?? UIColor.gray, UIColor(named: "dark")?.cgColor ?? UIColor.white]
            gradientLayer.frame = item.frame
            gradientLayer.cornerRadius = 30
            item.layer.insertSublayer(gradientLayer, at: 0) // 将背景图层插入到视图底部
            
            item.addSubview(name)
            item.addSubview(address)
            item.addSubview(time)
            item.addSubview(price)
            item.addSubview(info)
            item.addSubview(rating)
//            item.addSubview(locationBtn)
            
            resultView.addSubview(item)
            index+=1
        }
        
        location.coordinate = searchResults[0].coordinate
        mapView?.addAnnotation(location)
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 用户停止拖动时调用
        let offsetY = scrollView.contentOffset.y  // 获取垂直方向上的滚动位移
        let contentHeight = scrollView.contentSize.height  // 获取内容的总高度

        let percentageScrolled = offsetY / (contentHeight - scrollView.frame.height)

        // 根据滚动的百分比来计算当前查看的数据index
        let numberOfItems = searchResults.count
        let currentIndex = Int(percentageScrolled * CGFloat(numberOfItems - 1))

        // 打印当前的index
//        print("当前查看的数据index为：\(currentIndex)")
        location.coordinate = searchResults[currentIndex].coordinate
    }
    
    @objc func startNavigation() {
        
        let option = BMKOpenTransitRouteOption.init()
        //公交策略，默认：BMK_OPEN_TRANSIT_RECOMMAND(异常值，强制使用BMK_OPEN_TRANSIT_RECOMMAND)
        option.openTransitPolicy = BMK_OPEN_TRANSIT_RECOMMAND
        //指定返回自定义scheme
        option.appScheme = "baidumapsdk://mapsdk.baidu.com"
        //调起百度地图客户端失败后，是否支持调起web地图，默认：YES
        option.isSupportWeb = true
        //实例化线路检索节点信息类对象
        let start = BMKPlanNode.init()
        //指定起点名称
        start.name = "西直门"
        //指定起点经纬度
        start.pt = CLLocationCoordinate2DMake(39.90868, 116.204)
        //指定起点
        option.startPoint = start
        //实例化线路检索节点信息类对象
        let end = BMKPlanNode.init()
        //指定终点名称
        end.pt = CLLocationCoordinate2DMake(39.90868, 116.3956)
        //终点名称
        end.name = "天安门"
        //终点节点
        option.endPoint = end
        
        let flag =  BMKOpenRoute.openBaiduMapTransitRoute(option)
        if flag == BMK_OPEN_NO_ERROR {
            print("调起百度地图客户端公交路线界面成功！")
        }
        
        let para = BMKNaviPara.init()
        para.endPoint = BMKPlanNode.init()
        para.endPoint.pt = location.coordinate
//        let code = BMKNavigation.openBaiduMapWalk(para)
//        if code == BMK_OPEN_NO_ERROR {
//            print("调起百度地图客户端界面成功！")
//        }
        
    }
    
    @objc func refresh() {
        if ViewController.first {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            // 添加record
//            print("flag")
            let userFetchRequest: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
            userFetchRequest.predicate = NSPredicate(format: "uuid == %@", coreRootUser.uuid!) // 2
            do {
                let users = try managedContext.fetch(userFetchRequest)
                if let user = users.first {
                    // 接下来可以遍历用户的records，添加
                    if let records = user.records as? Set<CoreRecord> {
                        for record in records {
                            let newPaw = Paw()
                            newPaw.coordinate = CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude)
                            pawId = record.uuid ?? "defaultId"
                            mapView?.addAnnotation(newPaw)
                        }
                    }
                    // 保存更改
                    try managedContext.save()
                }
            } catch {
                print("Failed to add user records: \(error)")
            }
            ViewController.first = false
        }
        
    }
    
}
