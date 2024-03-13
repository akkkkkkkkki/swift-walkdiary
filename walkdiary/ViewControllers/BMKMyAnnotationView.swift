import Foundation
import UIKit

class BMKMyAnnotationView: BMKAnnotationView {
    var id = " "

    override init(annotation: BMKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        id = reuseIdentifier ?? " "

        //--------------------------自定义标注视图-------------------------------
        self.centerOffset = CGPoint(x: 0, y: 0)
        
        //--------------------------------------------------------------------
    }
    
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
    
    var animatesDrop: Bool = true
        
    func addAnimation() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        scaleAnimation.autoreverses = true
        scaleAnimation.isRemovedOnCompletion = false
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.3
        self.layer.add(scaleAnimation, forKey: "scale-layer")
    }
    
    func removeAnimation() {
        self.layer.removeAllAnimations()
    }
    
    func pauseAnimation() {
        let pausedTime = self.layer.convertTime(CACurrentMediaTime(), from: nil)
        self.layer.speed = 0.0
        self.layer.timeOffset = pausedTime
    }
    
    func resumeAnimation() {
        let pausedTime = self.layer.timeOffset
        self.layer.speed = 1.0
        self.layer.timeOffset = 0.0
        self.layer.beginTime = 0.0
        let timeSincePause = self.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.layer.beginTime = timeSincePause
    }
    
}

