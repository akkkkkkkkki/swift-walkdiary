import Foundation
import UIKit

class LineChartView: UIView {
    
    var dataPoints: [CGFloat] = [] // 最高温度数据
    var dataPointsLow: [CGFloat] = [] // 最低温度数据
    var weekdays: [String] = [] // 星期几
    
    init(frame: CGRect, dataPoints: [CGFloat], dataPointsLow: [CGFloat], weekdays: [String]) {
        self.dataPoints = dataPoints
        self.dataPointsLow = dataPointsLow
        self.weekdays = weekdays
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let maxXValue = CGFloat(dataPoints.count)
        let maxYValue = dataPoints.max()!
        let minYValue = dataPointsLow.min()!
        let path = UIBezierPath()
        
        UIColor.black.set() // 设置线条颜色为蓝色
        
        for (index, point) in dataPoints.enumerated() {
            let xPosition = rect.width / CGFloat(dataPoints.count) * CGFloat(index + 1)
            let yPosition = rect.height - (point - minYValue) * rect.height / (maxYValue - minYValue)
            if index == 0 {
                path.move(to: CGPoint(x: xPosition, y: yPosition))
            } else {
                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
            }
        }
        
        path.stroke()
        
        let pathLow = UIBezierPath()
        UIColor.black.set() // 设置线条颜色为红色
        
        for (index, point) in dataPointsLow.enumerated() {
            let xPositionLow = rect.width / CGFloat(dataPointsLow.count) * CGFloat(index + 1)
            let yPositionLow = rect.height - (point - minYValue) * rect.height / (maxYValue - minYValue)
            if index == 0 {
                pathLow.move(to: CGPoint(x: xPositionLow, y: yPositionLow))
            } else {
                pathLow.addLine(to: CGPoint(x: xPositionLow, y: yPositionLow))
            }
        }
        
        pathLow.stroke()
        
        // 标注 x 轴坐标（星期几）
        for (index, day) in weekdays.enumerated() {
            let xPosition = rect.width / maxXValue * CGFloat(index + 1)
            let label = UILabel(frame: CGRect(x: xPosition - 15, y: rect.height + 5, width: 50, height: 20))
            label.text = day
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.textColor = .black
            self.addSubview(label)
        }
        
        // 标注数据点（最高温度）
        for (index, point) in dataPoints.enumerated() {
            let xPosition = rect.width / maxXValue * CGFloat(index + 1)
            let yPosition = rect.height - (point - minYValue) * rect.height / (maxYValue - minYValue)
            let label = UILabel(frame: CGRect(x: xPosition - 15, y: yPosition - 25, width: 30, height: 20))
            label.text = "\(Int(point))°"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.textColor = .black
            self.addSubview(label)
        }
        
        // 标注数据点（最低温度）
        for (index, point) in dataPointsLow.enumerated() {
            let xPosition = rect.width / maxXValue * CGFloat(index + 1)
            let yPosition = rect.height - (point - minYValue) * rect.height / (maxYValue - minYValue)
            let label = UILabel(frame: CGRect(x: xPosition - 15, y: yPosition - 25, width: 30, height: 20))
            label.text = "\(Int(point))°"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textAlignment = .center
            label.textColor = .black
            self.addSubview(label)
        }
    }
}
