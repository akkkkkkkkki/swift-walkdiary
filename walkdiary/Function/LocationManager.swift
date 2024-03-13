//
//  Location.swift
//  walkdiary
//
//  Created by dyh on 2023/12/10.
//

import Foundation

class LocationService: NSObject {
    var mapManager: BMKLocationManager
    private var completionBlock: BMKLocatingCompletionBlock?
    
    override init() {
        mapManager = BMKLocationManager()
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        // 设置delegate
        mapManager.delegate = self

        // 设置返回位置的坐标系类型
        mapManager.coordinateType = .BMK09LL

        // 设置距离过滤参数
        mapManager.distanceFilter = kCLDistanceFilterNone

        // 设置预期精度参数
        mapManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        // 设置应用位置类型
        mapManager.activityType = CLActivityType.automotiveNavigation

        // 设置是否自动停止位置更新
        mapManager.pausesLocationUpdatesAutomatically = false

        // 设置位置获取超时时间
        mapManager.locationTimeout = 10

        // 设置获取地址信息超时时间
        mapManager.reGeocodeTimeout = 10
        
        // 连续定位
//        locationManager.startUpdatingLocation()
    }
    
    func startLocationService() {
        self.completionBlock = { (location: BMKLocation?, state: BMKLocationNetworkState, error: Error?) in
            if let error = error {
                print("LocError: {\(error._code) - \(error.localizedDescription)};")
            }
            
            if let location = location {
                if let loc = location.location {
                    print("Current location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
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
        
        mapManager.requestLocation(withReGeocode: true, withNetworkState: true, completionBlock: self.completionBlock!)
    }
}

// Conform to `BMKLocationManagerDelegate` if you need to handle additional delegate methods.
extension LocationService: BMKLocationManagerDelegate {
    // You can implement delegate methods here if needed
}
