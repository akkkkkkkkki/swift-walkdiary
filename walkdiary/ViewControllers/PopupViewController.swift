import Foundation
import CoreData
// 弹出的编辑框

class PopupViewController: UIViewController {
    weak var delegate: MyviewDelegate?
    let weatherList = ["sunny", "cloudy", "overcast", "sprinkle", "pour", "foggy", "snowy"]
    let emotionList = ["happy", "yummy", "mousy", "eye", "anxious", "speechless", "emo"]
    
    
    var weatherSelect = UIStackView()
    var weatherBtns = [UIButton]()
    var emotionSelect = UIView()
    var emotionBtns = [UIButton]()
    
    var weatherPushed: Bool = false
    var emotionPushed: Bool = false
    
    var selectedWeather = UIButton()
    var selectedEmotion = UIButton()
    
    let datePicker = UIDatePicker()
    let textView = UITextView()
    
    var coordinate = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRect(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight / 2)

        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "light")?.cgColor ?? UIColor.black, UIColor(named: "mid")?.cgColor ?? UIColor.gray, UIColor(named: "dark")?.cgColor ?? UIColor.white]
        gradientLayer.frame = CGRect(x: 0, y: screenHeight / 2, width: screenWidth, height: screenHeight / 2)
        gradientLayer.cornerRadius = 30
        view.layer.insertSublayer(gradientLayer, at: 0) // 将背景图层插入到视图底部
        gradientLayer.shadowRadius = 10
        
        // 设置弹出视图大小
        let alertWidth = Int(screenWidth)
        let alertHeight = Int(screenHeight) / 2
        let alertX = (Int(screenWidth) - alertWidth) / 2  // 居中显示
        let alertY = Int(screenHeight / 2)  // 在屏幕下半部分显示
        view.frame = CGRect(x: alertX, y: alertY, width: alertWidth, height: alertHeight)
        
        let btnWidth: CGFloat = 45
        let btnHeight: CGFloat = 40
        
        // 所有按钮
        let closeBtn = UIButton(frame: CGRect(x: view.frame.midX - 20, y: view.frame.minY + 5, width: 50, height: 50))
        let submitBtn = UIButton(frame: CGRect(x: (view.bounds.width - btnWidth - 20), y: view.frame.minY + 5, width: btnWidth, height: btnHeight))
        let weatherBtn = UIButton(frame: CGRect(x: (screenWidth/2 - 60), y: view.frame.maxY - btnHeight - 40, width: btnWidth, height: btnHeight))
        let emotionBtn = UIButton(frame: CGRect(x: (screenWidth/2 + 60), y: view.frame.maxY - btnHeight - 40, width: btnWidth, height: btnHeight))
        let clockBtn = UIButton(frame: CGRect(x: 40, y: view.frame.minY + 80, width: 35, height: 35))
        let editBtn = UIButton(frame: CGRect(x: 40, y: view.frame.minY + 150, width: 35, height: 35))
        
        // 关闭按钮
        closeBtn.setImage(UIImage(named: "close"), for: .normal)
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(closeBtn)
        
        // 提交按钮
        submitBtn.setImage(UIImage(named: "submit"), for: .normal)
        submitBtn.addTarget(self, action: #selector(submit), for: .touchUpInside)
        view.addSubview(submitBtn)
        
        // 设置选择天气按钮
        weatherBtn.setImage(UIImage(named: "weather"), for: .normal)
        createWeatherBtns()
        weatherBtn.addTarget(self, action: #selector(weatherBtnTapped), for: .touchUpInside)
        view.addSubview(weatherBtn)
        
        // 设置选择心情按钮
        emotionBtn.setImage(UIImage(named: "emotion"), for: .normal)
        createEmotionBtns()
        emotionBtn.addTarget(self, action: #selector(emotionBtnTapped), for: .touchUpInside)
        view.addSubview(emotionBtn)
        
        // 时钟icon
        clockBtn.setImage(UIImage(named: "clock"), for: .normal)
        clockBtn.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        view.addSubview(clockBtn)
        clockBtn.tag = 0
        
        // 时间选择器
        datePicker.frame = CGRect(x: 90, y: view.frame.minY + 73, width: view.frame.width - 150, height: 50)
        
        // 编辑icon
        editBtn.setImage(UIImage(named: "edit"), for: .normal)
        view.addSubview(editBtn)
        
        // 编辑框
        textView.frame = CGRect(x: 100, y: view.frame.minY + 150, width: view.frame.width - 150, height: 120)
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.layer.cornerRadius = 20
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.keyboardType = .asciiCapable
        textView.keyboardDismissMode = .interactiveWithAccessory
        view.addSubview(textView)
        
        
        // 左上角已选择天气按钮
        selectedWeather.frame = CGRect(x: 40, y: view.frame.minY + 15, width: 35, height: 35)
        selectedWeather.addTarget(self, action: #selector(resetWeather), for: .touchUpInside)
        selectedEmotion.frame = CGRect(x: 90, y: view.frame.minY + 15, width: 30, height: 30)
        selectedEmotion.addTarget(self, action: #selector(resetEmotion), for: .touchUpInside)
        
        selectedEmotion.alpha = 0.0
        selectedWeather.alpha = 0.0
        selectedWeather.tag = -1
        selectedEmotion.tag = -1
        
        view.addSubview(selectedWeather)
        view.addSubview(selectedEmotion)
        
        // 虚线
        let lineView = UIView(frame: CGRect(x: 30, y: view.frame.minY + 130, width: screenWidth - 60, height: 1))

        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [4, 4] // 设置虚线样式

        let path = CGMutablePath()
        path.addLines(between: [CGPoint.zero, CGPoint(x: lineView.bounds.width, y: 0)])
        shapeLayer.path = path

        lineView.layer.addSublayer(shapeLayer)

        // 将虚线视图添加到视图层级中
        self.view.addSubview(lineView)
        
        self.view.layer.shadowRadius = 3
//        self.view.layer.shadowColor
    }
    
    func createWeatherBtns() {
        let btnWidth: CGFloat = 40
        let btnHeight: CGFloat = 40
        
        weatherSelect.backgroundColor = UIColor.white
        weatherSelect.frame = CGRect(x: 40, y: view.frame.maxY - 140, width: screenWidth-80, height: 50)
        weatherSelect.layer.cornerRadius = weatherSelect.frame.height/2
        
        var i = 0
        for weather in weatherList {
            let x = CGFloat(i)*(btnWidth + 2) + 10
            let btn = UIButton(frame: CGRect(x: x, y: 5, width: btnWidth, height: btnHeight))
            btn.setImage(UIImage(named: weather), for: .normal)
            btn.tag = i
            weatherBtns.append(btn)
            weatherSelect.addSubview(btn)
            btn.addTarget(self, action: #selector(setWeather(_: )), for: .touchUpInside)
            i += 1
        }
    }
    
    func createEmotionBtns() {
        let btnWidth: CGFloat = 38
        let btnHeight: CGFloat = 38
        
        emotionSelect.backgroundColor = UIColor.white
        emotionSelect.frame = CGRect(x: 40, y: view.frame.maxY - 140, width: screenWidth-80, height: 50)
        emotionSelect.layer.cornerRadius = emotionSelect.frame.height/2
        
        var i = 0
        for emotion in emotionList {
            let x = CGFloat(i)*(btnWidth + 3) + 16
            let btn = UIButton(frame: CGRect(x: x, y: 5, width: btnWidth, height: btnHeight))
            btn.setImage(UIImage(named: emotion), for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(setEmotion(_:)), for: .touchUpInside)
            emotionBtns.append(btn)
            emotionSelect.addSubview(btn)
            i += 1
        }
        
    }
    
    @objc func submit() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: datePicker.date)
        let record: Record
        if (selectedEmotion.tag != -1 && selectedWeather.tag != -1) {
            record = Record(uuid: genRecordUuid(), date: String(date.split(separator: " ")[0]), time: String(date.split(separator: " ")[1]), content: textView.text, weather: weatherList[selectedWeather.tag], emotion: emotionList[selectedEmotion.tag])
        } else if (selectedEmotion.tag == -1 && selectedWeather.tag != -1) {
            record = Record(uuid: genRecordUuid(), date: String(date.split(separator: " ")[0]), time: String(date.split(separator: " ")[1]), content: textView.text, weather: weatherList[selectedWeather.tag])
        } else if (selectedEmotion.tag != -1 && selectedWeather.tag == -1) {
            record = Record(uuid: genRecordUuid(), date: String(date.split(separator: " ")[0]), time: String(date.split(separator: " ")[1]), content: textView.text, emotion: emotionList[selectedEmotion.tag])
        } else {
            record = Record(uuid: genRecordUuid(), date: String(date.split(separator: " ")[0]), time: String(date.split(separator: " ")[1]), content: textView.text)
        }
        
        rootUser.addRecord(id: record.uuid, record: record)
        
        // core data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let newRecord = NSEntityDescription.insertNewObject(forEntityName: "CoreRecord",
                                                            into: managedContext) as! CoreRecord
        newRecord.date = record.date
        newRecord.time = record.time
        newRecord.content = record.content
        newRecord.weather = record.weather
        newRecord.emotion = record.emotion
        newRecord.uuid = record.uuid
        newRecord.user = coreRootUser
        newRecord.latitude = coordinate.latitude
        newRecord.longitude = coordinate.longitude
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.delegate?.didDismissWithCoordinate(coordinate: coordinate, record: record, nsrecord: newRecord)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func close() {
        self.delegate?.didDismissAlone()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func weatherBtnTapped() {
        weatherPushed = !weatherPushed
        if (weatherPushed) {
            weatherSelect.alpha = 0.0
            self.view.addSubview(weatherSelect)
            UIView.animate(withDuration: 0.3) {
                self.weatherSelect.alpha = 1.0
            }
            self.view.addSubview(weatherSelect)
            if (emotionPushed) {
                emotionSelect.removeFromSuperview()
                emotionPushed = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.weatherSelect.alpha = 0.0
            }
            weatherSelect.removeFromSuperview()
        }
    }
    
    @objc func emotionBtnTapped() {
        emotionPushed = !emotionPushed
        if (emotionPushed) {
            emotionSelect.alpha = 0.0
            self.view.addSubview(emotionSelect)
            UIView.animate(withDuration: 0.3) {
                self.emotionSelect.alpha = 1.0
            }
            if (weatherPushed) {
                weatherSelect.removeFromSuperview()
                weatherPushed = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.emotionSelect.alpha = 0.0
            }
            emotionSelect.removeFromSuperview()
        }
    }
    
    @objc func setWeather(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.selectedWeather.alpha = 0.0 // 动画效果
        }
        
        let string = weatherList[sender.tag]
        selectedWeather.tag = sender.tag
        selectedWeather.setImage(UIImage(named: string), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.selectedWeather.alpha = 1.0 // 动画效果
        }
    }
    
    @objc func setEmotion(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.selectedEmotion.alpha = 0.0 // 动画效果
        }
        
        let string = emotionList[sender.tag]
        selectedEmotion.tag = sender.tag
        selectedEmotion.setImage(UIImage(named: string), for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.selectedEmotion.alpha = 1.0 // 动画效果
        }
    }
    
    @objc func resetWeather() {
        selectedWeather.alpha = 0.0
        selectedWeather.tag = -1
    }
    
    @objc func resetEmotion() {
        selectedEmotion.alpha = 0.0
        selectedEmotion.tag = -1
    }
    
    @objc func showDatePicker(_ sender: UIButton) {
        if (sender.tag == 0) {
            sender.tag = 1
            datePicker.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.datePicker.alpha = 1.0 // 动画效果
            }
            view.addSubview(datePicker)
        } else {
            sender.tag = 0
            UIView.animate(withDuration: 0.3) {
                self.datePicker.alpha = 0.0 // 动画效果
            }
            datePicker.removeFromSuperview()
        }
    }
    
    func setCoordinate(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
