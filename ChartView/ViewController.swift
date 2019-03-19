import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var horizontalChartView: ChartView!
    
    var animatedLayer: CALayer?
    var maskLayuer: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.dataSource = self
        horizontalChartView.dataSource = self
    }
    
    func mask() {
        let maskpath = CGMutablePath()
        maskpath.addEllipse(in: CGRect(x: 10, y: 10, width:30, height:30))
        maskpath.addEllipse(in: CGRect(x: 10, y: 60, width:30, height:30))
        maskpath.addEllipse(in: CGRect(x: 60, y: 10, width:30, height:30))
        maskpath.addEllipse(in: CGRect(x: 60, y: 60, width:30, height:30))
        // show path on layer
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        maskLayer.path = maskpath
        maskLayer.fillColor = UIColor.black.cgColor
        
        let starPath = CGMutablePath()
        starPath.move(to: CGPoint(x:19.098,y:100))
        starPath.addLine(to: CGPoint(x:25,y:63.82))
        starPath.addLine(to: CGPoint(x:-0,y:38.197))
        starPath.addLine(to: CGPoint(x:34.549,y:32.918))
        starPath.addLine(to: CGPoint(x:50,y:-0))
        starPath.addLine(to: CGPoint(x:65.451,y:32.918))
        starPath.addLine(to: CGPoint(x:100,y:38.197))
        starPath.addLine(to: CGPoint(x:75,y:63.82))
        starPath.addLine(to: CGPoint(x:80.902,y:100))
        starPath.addLine(to: CGPoint(x:50,y:82.918))
        starPath.closeSubpath()
        // show path on layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        //shapeLayer.path = starPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.borderColor = UIColor.gray.cgColor
        
        shapeLayer.mask = maskLayer
        view.layer.addSublayer(shapeLayer)
    }
    
    func drawBar() {
        let mainLayer = CAShapeLayer()
        mainLayer.frame = CGRect(x: 50, y: 50, width: 20, height: 100)
        mainLayer.contentsScale = UIScreen.main.scale
        
        mainLayer.backgroundColor = UIColor.lightGray.cgColor
        //mainLayer.fillColor = UIColor.lightGray.cgColor
        
        let components: [CGFloat] = [20, 10, 5, 30]
        let colors: [CGColor] = [UIColor.red.cgColor, UIColor.blue.cgColor, UIColor.green.cgColor, UIColor.brown.cgColor]
        for (index, component) in components.enumerated() {
            let color = colors[index]
            let layer = CALayer()
            layer.backgroundColor = color
            if index == 0 {
                let y = mainLayer.frame.size.height - component
                layer.frame = CGRect(x: 0, y: y, width: mainLayer.frame.size.width, height: component)
            } else {
                let subLayerAtBefore = mainLayer.sublayers?[index - 1] ?? CALayer()
                let y = subLayerAtBefore.frame.origin.y - component
                layer.frame = CGRect(x: 0, y: y, width: mainLayer.frame.size.width, height: component)
            }
            //mainLayer.addSublayer(layer)
        }
        
        let mainPath = CGMutablePath()
        //mainPath.addRect(mainLayer.bounds)
        
        let mask = self.maskLayer(mainLayer)
        self.maskLayuer = mask
        mainLayer.mask = mask
        
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.frame = mainLayer.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            UIColor.blue.cgColor,
            UIColor.blue.cgColor,
            UIColor.red.cgColor,
            UIColor.red.cgColor
        ]
        gradientLayer.locations = [
            0.0,
            0.5,
            0.5,
            0.7,
            0.7,
            1.0
        ]
        mainLayer.addSublayer(gradientLayer)
        self.animatedLayer = mainLayer
        self.view.layer.addSublayer(mainLayer)
        //self.animatedLayer?.isHidden = true
    }
    
    func maskLayer(_ mainLayer: CALayer) -> CALayer {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = CGRect(x: 0, y: 80, width: 20, height: 200)
        
        var maskOldFrame = mainLayer.bounds
        maskOldFrame.size.height -= 50
        maskOldFrame.origin.y += 50
        
        let maskPath = CGMutablePath()
        maskPath.addRect(maskOldFrame)
        
        //maskLayer.path = maskPath
        maskLayer.cornerRadius = 4
        //maskLayer.fillRule = .evenOdd
        //maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.backgroundColor = UIColor.black.cgColor
        
        return maskLayer
    }
    
    func animateLayer() {
        
        guard let maskLayer = self.maskLayuer else { return }
        
        let oldPosition = maskLayer.position
        debugPrint(oldPosition)
        var newPosition = oldPosition
        newPosition.y = oldPosition.y - 80
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = oldPosition
        animation.toValue = newPosition
        animation.duration = 1.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        maskLayer.add(animation, forKey: "animation")
        
        return
    }
    
}

extension ViewController:ChartViewDatasource {
    
    func numberOfSections(in chartView: ChartView) -> Int {
        return chartView == self.chartView ? 5 : 1
    }
    
    func chatrView(_ chartView: ChartView, hasSubChartInSection: Int) -> Bool {
        return false
    }
    
    func chartView(_ chartView: ChartView, chartDataInSection: Int) -> ChartData {
        return testData(chartDataInSection, chartView: chartView)
    }
    
    private func testData(_ inSection: Int, chartView: ChartView) -> ChartData {
        let components: [ChartDataComponent] = {
            let n: CGFloat = {
                if inSection == 0 {
                    return CGFloat(0.8)
                } else {
                    return CGFloat(inSection)
                }
            }()
            
            let first = MyChartDataComponent(data: n, color: UIColor(displayP3Red: 111/255, green: 119/255, blue: 201/255, alpha: 1.0).cgColor)
            let second = MyChartDataComponent(data: n, color: UIColor(displayP3Red: 88/255, green: 202/255, blue: 253/255, alpha: 1.0).cgColor)
            let third = MyChartDataComponent(data: n, color: UIColor(displayP3Red: 254/255, green: 179/255, blue: 95/255, alpha: 1.0).cgColor)
            let fourth = MyChartDataComponent(data: n, color: UIColor(displayP3Red: 151/255, green: 149/255, blue: 143/255, alpha: 1.0).cgColor)
            return [first, second, third, fourth]
        }()
        let firstPeriod: String = {
            if inSection < 2 {
                return "12/21"
            } else {
                return "先々週"
            }
        }()
        let endPeriod: String = {
            if inSection < 2 {
                return "12/31"
            } else {
                return "24-30"
            }
        }()
        
        let width: CGFloat = chartView == self.chartView ? 20 : 55
        
        var data = MyChartData(components: components, barWidth: width, subComponents: components, subBarWidth: 5, startPeriod: firstPeriod, endPeriod: endPeriod, timeDuration: "24:00")
        data.subComponents = components
        
        return data
    }
    
}

struct MyChartData: ChartData {
    var components: [ChartDataComponent]
    
    var barWidth: CGFloat
    
    var subComponents: [ChartDataComponent]?
    
    var subBarWidth: CGFloat?
    
    var startPeriod: String
    var endPeriod: String?
    var timeDuration: String
}

struct MyChartDataComponent: ChartDataComponent {
    var data: CGFloat
    
    var color: CGColor
    
    
}
