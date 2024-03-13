import Foundation

class CenterViewController: UIViewController, BMKWeatherSearchDelegate {
    
    let titleLabel = UILabel()
    let recordLabel = UILabel()
    let wordLabel = UILabel()
    let weatherView = UIView()
    
    var weatherData = BMKWeatherSearchNow()
    var searchResult = BMKWeatherSearchResult()
    
    //初始化BMKWeatherSearch实例
    let search = BMKWeatherSearch()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2) // 半透明效果  遮罩
        
        view.frame = CGRect(x: 50, y: screenHeight / 2 - 200, width: screenWidth - 100, height: 450)
        view.layer.cornerRadius = 30
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "light")?.cgColor ?? UIColor.black, UIColor(named: "mid")?.cgColor ?? UIColor.gray, UIColor(named: "dark")?.cgColor ?? UIColor.white]
        gradientLayer.frame = view.frame
        gradientLayer.cornerRadius = 30
        view.layer.insertSublayer(gradientLayer, at: 0) // 将背景图层插入到视图底部
        
        
        let fixedLabel1 = UILabel(frame: CGRect(x: 90, y: screenHeight/2 + 110, width: screenWidth - 70, height: 40))
        let fixedLabel2 = UILabel(frame: CGRect(x: 90, y: screenHeight/2 + 150, width: screenWidth - 70, height: 40))
        let fixedLabel3 = UILabel(frame: CGRect(x: 50, y: view.frame.maxY - 50, width: screenWidth - 100, height: 40))
        
        fixedLabel1.font = UIFont.systemFont(ofSize: 22)
        fixedLabel1.text = "已有记录"
        
        fixedLabel2.font = UIFont.systemFont(ofSize: 22)
        fixedLabel2.text = "总字数"
        
        fixedLabel3.font = UIFont.systemFont(ofSize: 12)
        fixedLabel3.textAlignment = .center
        fixedLabel3.text = "·个人中心·"
        
        titleLabel.frame = CGRect(x: 50, y: screenHeight/2 - 180, width: screenWidth - 100, height: 40)
        recordLabel.frame = CGRect(x: screenWidth/2 + 70, y: screenHeight/2 + 110, width: 50, height: 40)
        wordLabel.frame = CGRect(x: screenWidth/2 + 70, y: screenHeight/2 + 150, width: 100, height: 40)
        
        titleLabel.textAlignment = .center
        recordLabel.font = UIFont.systemFont(ofSize: 22)
        wordLabel.font = UIFont.systemFont(ofSize: 22)
        
        titleLabel.text = "在WalkDiary的第" + "\(rootUser.getRegisteredDate())" + "天"
        recordLabel.text = "\(getRecordCnt())" + "条"
        wordLabel.text = "\(getWordCnt())" + "字"
        
        view.addSubview(titleLabel)
        view.addSubview(fixedLabel1)
        view.addSubview(recordLabel)
        view.addSubview(fixedLabel2)
        view.addSubview(wordLabel)
        view.addSubview(fixedLabel3)
        
        // mark 天气查询
        search.delegate = self
        weatherSearch()
        
        // 手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func refresh() {  // todo，根据值变化自动更改
        titleLabel.text = "在WalkDiary的第" + "\(rootUser.getRegisteredDate())" + "天"
        recordLabel.text = "\(getRecordCnt())" + "条"
        wordLabel.text = "\(getWordCnt())" + "字"
    }
    
    func weatherSearch() {
        //初始化请求参数类BMKWeatherSearchOption的实例
        let option = BMKWeatherSearchOption()
        // 区县的行政区划编码
        option.districtID = "110108"
        //天气服务类型,默认国内
        option.serverType = BMKWeatherServerTypeDefault
        //天气数据类型
        option.dataType = BMKWeatherDataTypeAll
        //语言类型
        option.languageType = BMKLanguageTypeEnglish
        
        /**
         *weather搜索
         *param weatherSearchOption      weather检索信息类
         *异步函数，返回结果在BMKWeatherSearchDelegate的onGetWeatherResult通知
         *return 成功返回YES，否则返回NO
         */
        let flag = search.weatherSearch(option)
        if flag {
            print("天气查询检索发送成功")
        } else {
            print("天气查询检索发送失败")
        }
    }
    
    /**
     天气查询结果回调
     
     @param searcher 检索对象
     @param result 天气查询结果
     @param error 错误码，@see BMKCloudErrorCode
     */
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
    
    func showWeather() {
        let time = UILabel(frame: CGRect(x: self.view.frame.minX + 120, y: screenHeight/2 - 140, width: self.view.frame.width, height: 40))
        time.text = "数据更新于\(weatherData.updateTime)"
        time.textColor = .gray
        time.font = UIFont.systemFont(ofSize: 12)
        
        let location = UILabel(frame: CGRect(x: self.view.frame.minX + 100, y: screenHeight/2 - 100, width: 40, height: 40))
        location.text = "\(searchResult.location.districtName)"
        
        let icon = UIButton(frame: CGRect(x: location.frame.maxX, y: screenHeight/2 - 90, width: 20, height: 20))
        icon.setImage(UIImage(named: "location2"), for: .normal)
        
        let temp = UILabel(frame: CGRect(x: self.view.frame.minX + 100, y: screenHeight/2 - 75, width: self.view.frame.width, height: 40))
        temp.font = UIFont.systemFont(ofSize: 24)
        temp.text = "\(weatherData.temperature)"
        
        let phenomenon = UILabel(frame: CGRect(x: self.view.frame.minX + 135, y: screenHeight/2 - 75, width: self.view.frame.width, height: 40))
        phenomenon.text = "°C \(weatherData.phenomenon)"
        
        let icon2 = UIButton(frame: CGRect(x: location.frame.maxX + 70, y: screenHeight/2 - 90, width: 90, height: 90))
        
        let originalString = weatherData.updateTime
        let startIndex = originalString.index(originalString.startIndex, offsetBy: 7) // 第8个字符的索引是7
        let endIndex = originalString.index(originalString.startIndex, offsetBy: 8) // 第9个字符的索引是8
        let substring = Int(originalString[startIndex...endIndex]) ?? 12 // 使用索引来截取子字符串

        if (substring > 18 || substring < 6) {
            icon2.setImage(UIImage(named: "moon"), for: .normal)
        } else {
            icon2.setImage(UIImage(named: "day"), for: .normal)
        }
        

        
        
        var highTemperatures: [CGFloat] = []
        var lowTemperatures: [CGFloat] = []
        var date: [String] = []
        for i in 0...4 {
            highTemperatures.append(CGFloat(searchResult.forecasts[i].highestTemp))
            lowTemperatures.append(CGFloat(searchResult.forecasts[i].lowestTemp))
            date.append(searchResult.forecasts[i].week)
        }
        
        let fixedLabel4 = UILabel(frame: CGRect(x: self.view.frame.minX + 100, y: screenHeight/2 - 40, width: self.view.frame.width, height: 40))
        fixedLabel4.text = "五日天气预报"
        fixedLabel4.font = UIFont.systemFont(ofSize: 12)
        fixedLabel4.textColor = .darkGray
        
        let lineChartView = LineChartView(frame: CGRect(x: self.view.frame.minX+40, y: screenHeight/2+20, width: 260, height: 50), dataPoints: highTemperatures, dataPointsLow: lowTemperatures, weekdays: date)
        lineChartView.backgroundColor = .clear
        
        self.view.addSubview(fixedLabel4)
        self.view.addSubview(lineChartView)
        
        
        view.addSubview(time)
        view.addSubview(location)
        view.addSubview(icon)
        view.addSubview(icon2)
        view.addSubview(temp)
        view.addSubview(phenomenon)
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
        if distanceToTop < 150 || distanceToBottom < 150 || distanceToLeft < 50 || distanceToRight < 50 {
            // 点击的是边缘部分，执行关闭操作
            dismiss(animated: true, completion: nil)
        }
    }
}
