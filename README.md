WalkDairy设计文档
---

> walkdairy——看见你的足迹

### app简介

本项目是一款随手记app，以地图形式可视化用户的日记数据，支持添加、删除和本地保存；

同时也是一个生活小帮手，支持定位or选点检索周边地标（美食、住宿、生活资源）；同时添加天气服务，能够显示当前定位地点的天气状况以及未来五天的气温折线图；

当把7天24h投射在一张地图上的时候，或许会增加对时间的感知。

### 开发工具

```
语言: Swift
框架: Storyboard
IDE: Xcode
关键版本信息：
	Xcode: 14.0.1
	iOS: 16.0
	CocoaPods: 1.13.0
	BaiduMapKit: 6.5.8
	BaiduLocationKit 2.1.0
```

项目文件树如下：

```shell
│  AppDelegate.swift				# 代理函数
│  Info.plist						# 权限
│  SceneDelegate.swift
│  ViewController.swift				# 主界面
│
├─Assets.xcassets
│省略一堆图片文件……
├─Base.lproj
│      LaunchScreen.storyboard 		# APP的splash screen
│      Main.storyboard 				# 未使用
│
├─Modules							# 包含未持久化和持久化所使用的数据模型
│      CoreRecord+CoreDataClass.swift
│      CoreRecord+CoreDataProperties.swift
│      CoreUser+CoreDataClass.swift
│      CoreUser+CoreDataProperties.swift
│      Helper.swift
│      Record.swift
│      Restaurant.swift
│      SearchOptions.swift
│      UserData.swift
│      UserManager.swift
│
├─ViewControllers					# 各个子界面
│  │  BMKMyAnnotationView.swift		# 自定义annotation view，便于管理
│  │  CenterViewController.swift	# 个人中心
│  │  LineCharView.swift			# 气温折线图
│  │  Paw.swift						# record点
│  │  POI.swift						# poi点
│  │  POISearchViewController.swift	# 搜索界面
│  │  PopupViewController.swift		# 编辑record界面
│  │  RecordViewController.swift	# 显示record界面
│
└─walkdiary.xcdatamodeld			# coredata数据文件
    └─Model.xcdatamodel
            contents
```

### 功能介绍

#### 地图显示

- 主地图界面的显示、移动和缩放
- 识别长按手势事件
- 添加不同外观的地图annotation
- 点击annotation触发事件

#### 日记相关

- 对某个地图点编辑添加记录
- 点击地图点显示已添加的记录
- 删除指定记录
- 显示本地所有记录
- 显示本地所有记录的条目和字数

#### 定位相关

- 支持定位并移动地图到所在位置

#### 周边检索

- 支持关键字+距离+分类进行周边poi（point of interest）检索
- 详细展示检索结果，包括地名、地址、营业时间、均价、评分，并显示当前查看条目所在的地图位置

#### 天气服务

- 显示当前定位所在地温度和天气状况，并根据数据更新时间来显示day/moon图标
- 显示未来五天气温折线图

### 关键算法

#### 基础地图服务/定位

- 在viewcontroller中添加如下代码，即可显示一张全屏地图：

```swift
mapView = BMKMapView(frame: self.view.frame)
mapView?.delegate = self
self.view.addSubview(mapView!);
```

- 检测长按事件：

```swift
func mapview(_ mapView: BMKMapView, onLongClick coordinate: CLLocationCoordinate2D) {
    // ...
}
```

- 检测annotation点击：

  ```swift
  func mapView(_ mapView: BMKMapView, didSelect view: BMKAnnotationView) {
      let recordView = RecordViewController()
      recordView.delegate = self
      // ...
  }
  ```

- 定位，发起定位（completion block用法）

  ```swift
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
  ```

#### 添加/删除记录

> 主要描述整体delegate流程

- 用户编辑好信息后，在popupVC中将数据打包成`CoreRecord`类，调用代理方法

  ```swift
  func didDismissWithCoordinate(coordinate: CLLocationCoordinate2D, record: Record, nsrecord: CoreRecord)
  ```

- VC中代理实现

  ```swift
  func didDismissWithCoordinate(coordinate: CLLocationCoordinate2D, record: Record, nsrecord: CoreRecord) {
      mapView?.removeAnnotation(annotation)
      let newPaw = Paw()
      newPaw.coordinate = coordinate
  
      pawId = record.uuid
      mapView?.addAnnotation(newPaw)
  }
  ```

- recordVC建立时传record数据，点击recordVC的删除按钮时调用代理方法

  ```swift
  func didDeleteRecord(id: String)
  ```

- VC中实现代理方法

  ```swift
  func didDeleteRecord(id: String) {
      mapView?.removeAnnotation(pawViews[id]!.annotation)
  }
  ```

至此实现了annotation的添加和移除。

#### annotation个性化

> 百度地图的annotation外观支持自定义，但无论怎样都定义所有annotation类的对象外观，于是采用如下策略

- annotation的外观在回调方法中定义，所以需要重写回调方法

  ```swift
      func mapView(_ mapView: BMKMapView, viewFor annotation: BMKAnnotation) -> BMKAnnotationView?
  ```

- 我的实现方法是，自定义一个paw类继承百度地图的annotation类，并在方法中使用isKind()区分不同的annotation，给不同的image

  ```swift
  func mapView(_ mapView: BMKMapView, viewFor annotation: BMKAnnotation) -> BMKAnnotationView? {
      /**
       根据指定标识查找一个可被复用的标注，用此方法来代替新创建一个标注，返回可被复用的标注
       */
      if annotation.isKind(of: Paw.self) {
          var annotationView: BMKMyAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pawId) as? BMKMyAnnotationView
          if annotationView == nil {
              annotationView = BMKMyAnnotationView.init(annotation: annotation, reuseIdentifier: pawId)
          }
          annotationView?.image = UIImage.init(named: "paw")
          return annotationView
      } else if annotation.isKind(of: POI.self) {
          var annotationView: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationViewIdentifier") as? BMKPinAnnotationView
          if annotationView == nil {
              annotationView = BMKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "annotationViewIdentifier")
          }
          annotationView?.image = UIImage.init(named: "pin2")
          return annotationView
      } else if annotation.isKind(of: BMKPointAnnotation.self) {
          
          var annotationView: BMKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationViewIdentifier") as? BMKPinAnnotationView
          if annotationView == nil {
              annotationView = BMKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "annotationViewIdentifier")
          }
          annotationView?.image = UIImage.init(named: "pin")
          return annotationView
      }
      return nil
  }
  ```

#### poi信息检索/天气信息检索

> 实现百度地图接口

主要流程：

- 配置搜索参数，发起搜索
- 实现回调函数处理搜索结果

##### poi

```swift
func postSearch() {
    // 配置参数
    nearbyOption.keywords = []
    nearbyOption.keywords.append(searchBar.text ?? "饭店")
    nearbyOption.location = center
    nearbyOption.radius = distance
    nearbyOption.isRadiusLimit = false
    nearbyOption.scope = .BMK_POI_SCOPE_DETAIL_INFORMATION
    nearbyOption.filter = filter
    nearbyOption.pageIndex = 0
    nearbyOption.pageSize = 10
    nearbyOption.extensionsAdcode = true
    // 发起搜索
    let flag = poiSearch.poiSearchNear(by: nearbyOption)
    if flag {
        print("POI周边检索成功")
    } else {
        print("POI周边检索失败")
    }
}

// 回调函数
func onGetPoiResult(_ searcher: BMKPoiSearch, result poiResult: BMKPOISearchResult, errorCode: BMKSearchErrorCode) {
    if errorCode == BMK_SEARCH_NO_ERROR {
        //在此处理正常结果
        print("检索结果返回成功")
    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD) {
        print("检索词有歧义")
    } else {
        print(errorCode)
    }
    if (searchResult.count == 0) {
        // 弹出未找到消息框
    }
    self.delegate?.didPostSearch(searchResults: searchResult, distance: distance)
    dismiss(animated: true)
}
```

##### weather

```swift
func weatherSearch() {
    //配置参数
    let option = BMKWeatherSearchOption()
    option.districtID = "110108"
    option.serverType = BMKWeatherServerTypeDefault
    option.dataType = BMKWeatherDataTypeAll
    option.languageType = BMKLanguageTypeEnglish
    // 发起搜索
    let flag = search.weatherSearch(option)
    if flag {
        print("天气查询检索发送成功")
    } else {
        print("天气查询检索发送失败")
    }
}

// 回调函数
func onGetWeatherResult(_ searcher: BMKWeatherSearch, result: BMKWeatherSearchResult, errorCode error: BMKSearchErrorCode) {
    if error == BMK_SEARCH_NO_ERROR {
        //在此处理正常结果
        searchResult = result
        weatherData = result.realTimeWeather
    }
    else {
        print("查询失败");
    }
    showWeather()
}
```

### 项目亮点

1. 接入百度地图sdk，实现显示地图、标记地图、手势交互、poi检索、天气检索、定位等接口，极大的丰富了app的功能和可用性；
2. 整体界面简洁美观，交互性好，用户友好度高。

### 主要截图

![总截图1](D:\Documents\大三上\swift\walkdiary\总截图1.jpg)

**参考**

百度地图开发文档：https://lbsyun.baidu.com/faq/api?title=iossdk

类参考：https://mapopen-pub-iossdk.cdn.bcebos.com/map/v6_6_0/docs/html/index.html

