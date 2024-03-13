import Foundation
import CoreData

class RecordViewController: UIViewController {
    weak var delegate: MyviewDelegate?
    
    var record = Record(uuid: " ", date: "yyyy mm dd", time: "hh:mm", content: "content")
    var coreRecord = CoreRecord()
    let deleteBtn = UIButton()
    let confirmBtn = UIButton()
    let weather = UIButton()
    let emotion = UIButton()
    
    var tapGesture = UITapGestureRecognizer()
    var tapGesture2 = UITapGestureRecognizer()

    
    override func viewDidLoad() {
        self.view.frame = CGRect(x: 50, y: screenHeight / 2 + 100, width: screenWidth - 100, height: 250)
        self.view.layer.shadowRadius = 10
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "light")?.cgColor ?? UIColor.black, UIColor(named: "mid")?.cgColor ?? UIColor.gray, UIColor(named: "dark")?.cgColor ?? UIColor.white]
        gradientLayer.frame = view.frame
        gradientLayer.cornerRadius = 30
        view.layer.insertSublayer(gradientLayer, at: 0) // 将背景图层插入到视图底部
        
        let dateLabel = UILabel(frame: CGRect(x: self.view.frame.minX + 30, y: self.view.frame.minY + 55, width: 100, height: 30))
        let timeLabel = UILabel(frame: CGRect(x: self.view.frame.maxX - 80, y: self.view.frame.minY + 55, width: 100, height: 30))
        let contentLabel = UILabel(frame: CGRect(x: self.view.frame.minX + 30, y: self.view.frame.minY + 80, width: self.view.frame.width - 100, height: 70))
        
        dateLabel.text = coreRecord.date
        timeLabel.text = coreRecord.time
        contentLabel.text = coreRecord.content
        
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        contentLabel.font = UIFont.systemFont(ofSize: 12)
        
        
        deleteBtn.frame = CGRect(x: self.view.frame.maxX - 50, y: self.view.frame.maxY - 50, width: 20, height: 20)
        deleteBtn.setImage(UIImage(named: "delete"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(clickDelete), for: .touchUpInside)
        
        confirmBtn.frame = CGRect(x: self.view.frame.maxX - 60, y: self.view.frame.maxY - 65, width: 50, height: 50)
        confirmBtn.setTitle("确认", for: .normal)
        confirmBtn.setTitleColor(UIColor.black, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        confirmBtn.addTarget(self, action: #selector(clickConfirm), for: .touchUpInside)
        
        // 天气和心情显示
        weather.frame = CGRect(x: self.view.frame.maxX - 100, y: view.frame.minY + 15, width: 35, height: 35)
        emotion.frame = CGRect(x: self.view.frame.maxX - 60, y: view.frame.minY + 15, width: 30, height: 30)
        if let emotionString = coreRecord.emotion {
            emotion.setImage(UIImage(named: emotionString), for: .normal)
        }
        if let weatherString = coreRecord.weather {
            weather.setImage(UIImage(named: weatherString), for: .normal)
        }
        
        
        self.view.addSubview(dateLabel)
        self.view.addSubview(timeLabel)
        self.view.addSubview(contentLabel)
        self.view.addSubview(deleteBtn)
        self.view.addSubview(weather)
        self.view.addSubview(emotion)
        
        // 虚线
        let lineView = UIView(frame: CGRect(x: self.view.frame.minX + 20, y: view.frame.minY + 90, width: self.view.frame.width - 40, height: 1))

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
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTap2(_:)))
        view.addGestureRecognizer(tapGesture2)
    }
    
    @objc func clickDelete() {
        UIView.animate(withDuration: 0.2) {
            self.deleteBtn.alpha = 0.0 // 动画效果
        }
        deleteBtn.removeFromSuperview()
        
        self.view.addSubview(confirmBtn)
        
        // 手势识别器
        view.addGestureRecognizer(tapGesture)
        view.removeGestureRecognizer(tapGesture2)
    }
    
    @objc func clickConfirm() {
        // 把record删除掉。 usrmanager单例模式写删除函数
        
//        self.view.removeFromSuperview()
        self.delegate?.didDeleteRecord(id: coreRecord.uuid ?? record.uuid)
        // 假设userId是你要删除记录的User的ID
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
                        if record.uuid == self.coreRecord.uuid {
                            user.removeFromRecords(record)
                            managedContext.delete(record)
                        }
                    }
                }
                // 保存更改
                try managedContext.save()
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }

        dismiss(animated: true, completion: nil)

    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        // 计算点击位置到目标view边缘的距离
        let distanceToTop = location.y
        let distanceToBottom = screenHeight - location.y
        let distanceToLeft = location.x
        let distanceToRight = screenWidth - location.x
        
        // 判断点击位置是否在目标view的边缘，并根据需要执行相应的关闭操作
        if distanceToTop < 500 || distanceToBottom < 100 || distanceToLeft < 250 || distanceToRight < 30 {
            // 点击的是边缘部分，执行关闭操作
            UIView.animate(withDuration: 0.2) {
                self.confirmBtn.alpha = 0.0 // 动画效果
            }
            confirmBtn.removeFromSuperview()
            confirmBtn.alpha = 1.0
            self.view.addSubview(deleteBtn)
            deleteBtn.alpha = 1.0
            view.addGestureRecognizer(tapGesture2)
        }
    }
    
    @objc func handleTap2(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        // 计算点击位置到目标view边缘的距离
        let distanceToTop = location.y
        let distanceToBottom = screenHeight - location.y
        
        // 判断点击位置是否在目标view的边缘，并根据需要执行相应的关闭操作
        if distanceToTop < screenHeight / 2 + 60 || distanceToBottom < 30  {
            // 点击的是边缘部分，执行关闭操作
            self.delegate?.didDismissAlone()
            dismiss(animated: true, completion: nil)
        }
    }
}
