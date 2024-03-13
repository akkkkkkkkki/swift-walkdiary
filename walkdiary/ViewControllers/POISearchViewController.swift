import Foundation
import UIKit


class POISearchViewController: UIViewController, BMKPoiSearchDelegate, BMKGeoCodeSearchDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let nearbyOption = BMKPOINearbySearchOption()
    
    weak var delegate: MyviewDelegate?
    let searchBar = UISearchBar()
    let poiSearch = BMKPoiSearch()
    let searchBtn = UIButton()
    let searchText = UITextField()
    let distancePicker = UIPickerView()
    let flowLayout = UICollectionViewFlowLayout()
    
    var center = CLLocationCoordinate2DMake(40.051231, 116.282051)
    
    var searchResult: [Restaurant] = []
    
    let distances = [500, 1000, 2000, 5000, 100000]
    var distance = 5000
    let filter = BMKPOISearchFilter()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        distancePicker.delegate = self
        distancePicker.dataSource = self
    }
    
    override func viewDidLoad() {
        //此处需要先遵循协议<BMKPoiSearchDelegate>
        poiSearch.delegate = self
        
        view.frame = CGRect(x: 50, y: screenHeight / 2 - 200, width: screenWidth - 100, height: 300)
        view.layer.cornerRadius = 30
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "light")?.cgColor ?? UIColor.black, UIColor(named: "light")?.cgColor ?? UIColor.gray, UIColor(named: "mid")?.cgColor ?? UIColor.white]
        gradientLayer.frame = view.frame
        gradientLayer.cornerRadius = 30
        view.layer.insertSublayer(gradientLayer, at: 0) // 将背景图层插入到视图底部
        
        searchBar.frame = CGRect(x: view.frame.minX + 20, y: view.frame.minY + 20, width: view.frame.width - 100, height: 50)
        searchBar.backgroundColor = .clear
        searchBar.layer.cornerRadius = 10
        self.view.addSubview(searchBar)
        
        searchBtn.frame = CGRect(x: searchBar.frame.maxX + 5, y: view.frame.minY + 25, width: 60, height: 40)
        searchBtn.setTitle("search", for: .normal)
        searchBtn.setTitleColor(UIColor.black, for: .normal)
        searchBtn.backgroundColor = UIColor(named: "mid")
        searchBtn.layer.cornerRadius = 10
        searchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        searchBtn.addTarget(self, action: #selector(startSearch), for: .touchUpInside)
        
        distancePicker.frame = CGRect(x: self.view.frame.minX + 50, y: searchBar.frame.maxY+5, width: 200, height: 80)
        self.view.addSubview(distancePicker)
        distancePicker.isUserInteractionEnabled = true
        
        // 在这里添加tag的选择
//
//        //定义每个cell的大小
//        flowLayout.itemSize = CGSize(width: 50, height: 30)
//        //定义布局方向
//        flowLayout.scrollDirection = .vertical
//        //定义每个cell纵向的间距
//        flowLayout.minimumLineSpacing = 10
//        //定义每个cell的横向间距
//        flowLayout.minimumInteritemSpacing = 5
//        //定义每个cell到容器边缘的距离
//        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
//
//        let collectionView = UICollectionView(frame: CGRect(x: self.view.frame.minX, y: distancePicker.frame.maxY+20, width: self.view.frame.width, height: 180), collectionViewLayout: flowLayout)
//        //注册cell
//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
//        //设置代理
//        collectionView.delegate = self
//        //设置数据源
//        collectionView.dataSource = self
//
//        collectionView.backgroundColor = .clear
//        collectionView.selfSizingInvalidation = .enabled
//        self.view.addSubview(collectionView)
        
        // tag选择
        let switcher = UISegmentedControl(items: ["美食", "酒店", "生活", "运动"])
        switcher.frame = CGRect(x: self.view.frame.minX+20, y: distancePicker.frame.maxY+20, width: self.view.frame.width-40, height: 40)
        switcher.selectedSegmentIndex = 0 // 默认选中第一个选项
        switcher.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        view.addSubview(switcher)
        
        
        view.addSubview(searchBtn)
        
        
        let closeBtn = UIButton(frame: CGRect(x: screenWidth/2 - 25, y: view.frame.maxY - 50, width: 50, height: 50))
        closeBtn.setImage(UIImage(named: "exit"), for: .normal)
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
//        view.addSubview(closeBtn)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return titles.count
//    }
    
//    // 数据源
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//        cell.layer.cornerRadius = 10
//        cell.backgroundColor = .white
//        let tagLabel = UILabel(frame: cell.contentView.frame)
//        cell.contentView.addSubview(tagLabel)
//        tagLabel.text = titles[indexPath.item % titles.count]
//        return cell
//    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, widthForItemAtIndexPath indexPath: IndexPath) -> CGSize {
//        let cnt = titles[indexPath.item % 2].count
//        print(cnt)
//        return CGSizeMake(CGFloat(cnt*15), 30)
//    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // 选择了“美食”
            nearbyOption.tags = ["美食"]
            filter.industryType = .BMK_POI_INDUSTRY_TYPE_CATER
            break
        case 1:
            // 选择了“酒店”
            nearbyOption.tags = ["酒店"]
            filter.industryType = .BMK_POI_INDUSTRY_TYPE_HOTEL
            break
        case 2:
            // 选择了“生活”
            nearbyOption.tags = ["生活服务", "购物", "休闲娱乐", "丽人", "医疗"]
            filter.industryType = .BMK_POI_INDUSTRY_TYPE_LIFE
            break
        case 3:
            nearbyOption.tags = ["运动健身"]
            filter.industryType = .BMK_POI_INDUSTRY_TYPE_LIFE
            break
        default:
            break
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.distances.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = "\(distances[row])m"
        titleLabel.textAlignment = .center
        return titleLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        distance = distances[row]
    }
    
    
    
    
    
    @objc func startSearch() {
        postSearch()
    }
    
    func postSearch() {
        searchResult.removeAll()
        //初始化请求参数类BMKNearbySearchOption的实例
        /**
         检索关键字，必选。
         在周边检索中关键字为数组类型，可以支持多个关键字并集检索，如银行和酒店。每个关键字对应数组一个元素。
         最多支持10个关键字。
         */
        nearbyOption.keywords = []
        nearbyOption.keywords.append(searchBar.text ?? "饭店")
        //检索中心点的经纬度，必选
        nearbyOption.location = center
        /**
         检索半径，单位是米。
         当半径过大，超过中心点所在城市边界时，会变为城市范围检索，检索范围为中心点所在城市
         */
        nearbyOption.radius = distance
        /**
         检索分类，可选。
         该字段与keywords字段组合进行检索。
         支持多个分类，如美食和酒店。每个分类对应数组中一个元素
         */
        /**
         是否严格限定召回结果在设置检索半径范围内。默认值为false。
         值为true代表检索结果严格限定在半径范围内；值为false时不严格限定。
         注意：值为true时会影响返回结果中total准确性及每页召回poi数量，我们会逐步解决此类问题。
         */
        nearbyOption.isRadiusLimit = false
        nearbyOption.scope = .BMK_POI_SCOPE_DETAIL_INFORMATION
        /**
         POI检索结果详细程度
         
         BMK_POI_SCOPE_BASIC_INFORMATION: 基本信息
         BMK_POI_SCOPE_DETAIL_INFORMATION: 详细信息
         */
//        nearbyOption.scope = BMKPOISearchScopeType.BMK_POI_SCOPE_DETAIL_INFORMATION
        //检索过滤条件，scope字段为BMK_POI_SCOPE_DETAIL_INFORMATION时，filter字段才有效
        
        nearbyOption.filter = filter
        //分页页码，默认为0，0代表第一页，1代表第二页，以此类推
        nearbyOption.pageIndex = 0
        //单次召回POI数量，默认为10条记录，最大返回20条。
        nearbyOption.pageSize = 10
        
        // 返回行政区划
        nearbyOption.extensionsAdcode = true
        
        /**
         根据中心点、半径和检索词发起周边检索：异步方法，返回结果在BMKPoiSearchDelegate
         的onGetPoiResult里
         
         nearbyOption 周边搜索的搜索参数类
         成功返回YES，否则返回NO
         */
        let flag = poiSearch.poiSearchNear(by: nearbyOption)
        if flag {
            print("POI周边检索成功")
        } else {
            let alert = UIAlertController(title: "没有结果", message: "请输入正确的关键词", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            print("POI周边检索失败")
        }
    }
    
    /**
     POI检索返回结果回调
     
     @param searcher 检索对象
     @param poiResult POI检索结果列表
     @param error 错误码
     */
    func onGetPoiResult(_ searcher: BMKPoiSearch, result poiResult: BMKPOISearchResult, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            //在此处理正常结果
            for poi in poiResult.poiInfoList {
                addResult(info: poi)
            }
            print("检索结果返回成功")
        }
        else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD) {
            print("检索词有歧义")
        } else {
            print(errorCode)
        }
        if (searchResult.count == 0) {
            let alert = UIAlertController(title: "没有结果", message: "抱歉，没有找到相关结果，请更换关键词", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        self.delegate?.didPostSearch(searchResults: searchResult, distance: distance)
        dismiss(animated: true)
    }
    
    func poiDetailSearch(uuid: String) {
        //初始化请求参数类BMKPoiDetailSearchOption的实例
        let detailOption = BMKPOIDetailSearchOption()
        //POI的唯一标识符集合，必选
        detailOption.poiUIDs = []
        detailOption.poiUIDs.append(uuid)
        /**
         POI检索结果详细程度
         
         BMK_POI_SCOPE_BASIC_INFORMATION: 基本信息
         BMK_POI_SCOPE_DETAIL_INFORMATION: 详细信息
         */
        detailOption.scope = BMKPOISearchScopeType.BMK_POI_SCOPE_DETAIL_INFORMATION
        
        /**
         根据POI UID 发起POI详情检索：异步方法，返回结果在BMKPoiSearchDelegate
         的onGetPoiDetailResult里
         detailOption POI详情检索参数类
         成功返回YES，否则返回NO
         */
        let flag = poiSearch.poiDetailSearch(detailOption)
        if flag {
            print("POI详情检索成功")
        } else {
            print("POI详情检索失败")
        }
    }
    
    /**
     POI详情检索结果回调
     
     @param searcher 检索对象
     @param poiDetailResult POI详情检索结果
     @param errorCode 错误码，@see BMKCloudErrorCode
     */
    func onGetPoiDetailResult(_ searcher: BMKPoiSearch!, result poiDetailResult: BMKPOIDetailSearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            //在此处理正常结果
            for poi in poiDetailResult.poiInfoList {
                addResult(info: poi)
            }
            print("检索结果返回成功")
        }
        else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD) {
            print("检索词有歧义")
        } else {
            print("其他检索结果错误码相关处理")
        }
    }
    
    func addResult(info: BMKPoiInfo) {
        if let detail = info.detailInfo { // 增加鲁棒性
            searchResult.append(Restaurant(info: info, detail: detail))
        }
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // 手势处理方法
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        // 计算点击位置到目标view边缘的距离
        let distanceToTop = location.y
        let distanceToBottom = screenHeight - location.y
        let distanceToLeft = location.x
        let distanceToRight = screenWidth - location.x
        
        // 判断点击位置是否在目标view的边缘，并根据需要执行相应的关闭操作
        if distanceToTop < screenHeight / 2 - 200 || distanceToBottom < screenHeight / 2 - 200 || distanceToLeft < 50 || distanceToRight < 50 {
            // 点击的是边缘部分，执行关闭操作
            dismiss(animated: true, completion: nil)
        }
    }
}
