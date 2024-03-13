import Foundation

class LogRegViewController: UIViewController {
    let submitBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = CGRect(x: 50, y: screenHeight/2 - 100, width: screenWidth - 100, height: 200)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2) // 半透明效果  遮罩

        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(named: "dark")?.cgColor ?? UIColor.black, UIColor(named: "mid")?.cgColor ?? UIColor.gray, UIColor(named: "light")?.cgColor ?? UIColor.white]
        gradientLayer.frame = view.frame
        gradientLayer.cornerRadius = 30
        view.layer.insertSublayer(gradientLayer, at: 0) // 将背景图层插入到视图底部
        
        let loginLabel = UILabel(frame: CGRect(x: screenWidth/2 - 60, y: screenHeight/2 - 80, width: 120, height: 40))
        loginLabel.text = "请先登录"
        loginLabel.textAlignment = .center
        
        let usernameText = UITextField(frame: CGRect(x: screenWidth/2 - 100, y: screenHeight/2 - 20, width: 200, height: 40))
        usernameText.font = UIFont.systemFont(ofSize: 20)
        usernameText.backgroundColor = UIColor.white
        usernameText.layer.cornerRadius = 17
        usernameText.textAlignment = .center
        usernameText.keyboardType = .alphabet
        
        submitBtn.frame = CGRect(x: self.view.frame.midX - 30, y: self.view.frame.maxY - 60, width: 60, height: 40)
        submitBtn.layer.cornerRadius = 30
        submitBtn.backgroundColor = UIColor.black
        submitBtn.setTitleColor(UIColor.white, for: .normal)
        submitBtn.setTitle("确认", for: .normal)
        
        
        self.view.addSubview(loginLabel)
        self.view.addSubview(usernameText)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: view)
        
        // 计算点击位置到目标view边缘的距离
        let distanceToTop = location.y
        let distanceToBottom = screenHeight - location.y
        let distanceToLeft = location.x
        let distanceToRight = screenWidth - location.x
        
        // 判断点击位置是否在目标view的边缘，并根据需要执行相应的关闭操作
        if distanceToTop < 300 || distanceToBottom < 300 || distanceToLeft < 50 || distanceToRight < 50 {
            // 点击的是边缘部分，执行关闭操作
            dismiss(animated: true, completion: nil)
        }
    }
}
