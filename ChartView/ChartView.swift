import UIKit

class ChartView: UIView {
    
    weak var dataSource: ChartViewDatasource?
    
    public var mainLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let mainLayer = CAShapeLayer()
        mainLayer.contentsScale = UIScreen.main.scale
        self.mainLayer = mainLayer
        self.layer.addSublayer(mainLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainLayer.frame = self.bounds
    }
    
    override func draw(_ rect: CGRect) {
        drawChart()
    }
    
    internal func drawChart() {
        
        guard let dataSource = self.dataSource else { return }
        
        let section = dataSource.numberOfSections(in: self)
        
        let periodFrameHeight: CGFloat = 36
        let timeDurationFrameHeight: CGFloat = 16
        
        let drawRects: [CGRect] = {
            let widthPerSection = self.bounds.width / CGFloat(section)
            let height = self.bounds.height - periodFrameHeight - timeDurationFrameHeight
            let y: CGFloat = periodFrameHeight
            var rects: [CGRect] = []
            for section in 0..<section {
                let rect = CGRect(x: CGFloat(section) * widthPerSection, y: y, width: widthPerSection, height: height)
                rects.append(rect)
            }
            return rects
        }()
        
        for section in 0..<section {
            
            let chartData = dataSource.chartView(self, chartDataInSection: section)
            let barHeight: CGFloat = drawRects[section].size.height
            
            let chartLayer = CALayer()
            chartLayer.contentsScale = UIScreen.main.scale
            let drawRectsInSection = drawRects[section]
            chartLayer.frame = drawRectsInSection
            
            // Period
            let startPeriodLayerHeight: CGFloat = 20.0
            let startPeriodLayer: CATextLayer = CATextLayer()
            startPeriodLayer.frame = CGRect(x: CGFloat(section) * drawRectsInSection.size.width, y: 0, width: drawRectsInSection.size.width, height: startPeriodLayerHeight)
            startPeriodLayer.contentsScale = UIScreen.main.scale
            startPeriodLayer.string = (chartData.endPeriod != nil) ? chartData.startPeriod + "~" : chartData.startPeriod
            startPeriodLayer.foregroundColor = UIColor(displayP3Red: 209/255, green: 209/255, blue: 214/255, alpha: 1.0).cgColor
            startPeriodLayer.fontSize = 12
            startPeriodLayer.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            startPeriodLayer.alignmentMode = .center
            self.mainLayer.addSublayer(startPeriodLayer)
            
            if let endPeriod = chartData.endPeriod {
                let endPeriodLayer: CATextLayer = CATextLayer()
                endPeriodLayer.frame = CGRect(x: CGFloat(section) * drawRectsInSection.size.width, y: startPeriodLayer.bounds.size.height, width: drawRectsInSection.size.width, height: periodFrameHeight - startPeriodLayerHeight)
                endPeriodLayer.contentsScale = UIScreen.main.scale
                endPeriodLayer.string = endPeriod
                endPeriodLayer.foregroundColor = UIColor(displayP3Red: 209/255, green: 209/255, blue: 214/255, alpha: 1.0).cgColor
                endPeriodLayer.fontSize = 12
                endPeriodLayer.alignmentMode = .center
                self.mainLayer.addSublayer(endPeriodLayer)
            }
            
            // Time Duration
            let timeDurationLayer: CATextLayer = CATextLayer()
            timeDurationLayer.frame = CGRect(x: CGFloat(section) * drawRectsInSection.size.width, y: (drawRectsInSection.height + drawRectsInSection.origin.y), width: drawRectsInSection.size.width, height: timeDurationFrameHeight)
            timeDurationLayer.contentsScale = UIScreen.main.scale
            timeDurationLayer.string = chartData.timeDuration
            timeDurationLayer.foregroundColor = UIColor(displayP3Red: 209/255, green: 209/255, blue: 214/255, alpha: 1.0).cgColor
            timeDurationLayer.fontSize = 12
            timeDurationLayer.alignmentMode = .center
            self.mainLayer.addSublayer(timeDurationLayer)
            
            self.drawChart(in: chartLayer, in: drawRectsInSection, chartData: chartData, barHeight: barHeight)
            
        }
        
        
        
    }
    
    internal func colorsLocationsAndTotalPercentage(_ components: [ChartDataComponent]) -> ([CGColor], [CGFloat], CGFloat) {
        
        //TODO: - Set Temporary
        let maxTime: CGFloat = 24
        
        var colors: [CGColor] = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor
        ]
        
        var locations: [CGFloat] = [
            0.0
        ]
        
        let totalPercentage: CGFloat = {
            var total: CGFloat = 0.0
            for component in components {
                total += component.data / maxTime
            }
            return total
        }()
        let leftPercentage = 1 - totalPercentage
        locations.append(leftPercentage)
        locations.append(leftPercentage)
        var accumulationPercentage: CGFloat = leftPercentage
        
        for (index, component) in components.reversed().enumerated() {
            let percentage = component.data / maxTime
            
            locations.append(percentage + accumulationPercentage)
            
            if index + 1 < components.count {
                locations.append((percentage + accumulationPercentage))
            }
            
            accumulationPercentage += percentage
            colors.append(contentsOf: [component.color, component.color])
        }
        
        return (colors, locations, totalPercentage)
    }
    
    private func drawChart(in layer: CALayer, in rect: CGRect, chartData: ChartData, barHeight: CGFloat) {
        
        // Main Chart
        let tuple = self.colorsLocationsAndTotalPercentage(chartData.components)
        let colors: [CGColor] = tuple.0
        let locations: [CGFloat] = tuple.1
        let totalPercentage: CGFloat = tuple.2
        
        let gradientLayer = CAGradientLayer()
        let originX = rect.size.width / 2 - chartData.barWidth / 2
        gradientLayer.frame = CGRect(x: originX, y: 0, width: chartData.barWidth, height: barHeight)
        gradientLayer.colors = colors
        gradientLayer.locations = locations.map { NSNumber(value: Float($0)) }
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.mask = self.topRoundedCornersMask(for: gradientLayer, leftPercentage: (1 - totalPercentage))
        
        if let subComponents = chartData.subComponents {
            let tuple = self.colorsLocationsAndTotalPercentage(subComponents)
            let colors: [CGColor] = tuple.0
            let locations: [CGFloat] = tuple.1
            let totalPercentage: CGFloat = tuple.2
            let barWidth = chartData.subBarWidth ?? 5
            let mergin: CGFloat = 3.0
            
            // Reposition Main Chart
            var mainChartFrame = gradientLayer.frame
            mainChartFrame.origin.x -= (mergin + barWidth) / 2
            gradientLayer.frame = mainChartFrame
            
            let subGradientLayer = CAGradientLayer()
            let originX = gradientLayer.frame.origin.x + gradientLayer.frame.width + mergin
            subGradientLayer.frame = CGRect(x: originX, y: 0, width: barWidth, height: barHeight)
            subGradientLayer.colors = colors
            subGradientLayer.locations = locations.map { NSNumber(value: Float($0)) }
            subGradientLayer.contentsScale = UIScreen.main.scale
            subGradientLayer.mask = self.topRoundedCornersMask(for: subGradientLayer, leftPercentage: (1 - totalPercentage))
            layer.addSublayer(subGradientLayer)
        }
        
        
        layer.addSublayer(gradientLayer)
        self.mainLayer.addSublayer(layer)
    }
    
    private func topRoundedCornersMask(for layer: CALayer, leftPercentage: CGFloat) -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        let frame = layer.bounds
        maskLayer.frame = frame
        var pathBounds = frame
        pathBounds.size.height *= 1.0 - leftPercentage
        pathBounds.origin.y = frame.size.height - pathBounds.size.height
        
        let bezielPath = UIBezierPath(roundedRect: pathBounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 3.0, height: 3.0))
        UIColor.black.setFill()
        maskLayer.path = bezielPath.cgPath
        return maskLayer
    }
    
    internal func animateChart() {
        
    }
}

class HorizontalChartView: ChartView {
    
    override func drawChart() {
        
        guard let dataSource = self.dataSource else { return }
        
        let section = dataSource.numberOfSections(in: self)
        
        let timeDurationFrameWidth: CGFloat = 50
        
        let drawRects: [CGRect] = {
            let heightPerSection = self.bounds.height / CGFloat(section)
            let width = self.bounds.width
            let y: CGFloat = 0
            var rects: [CGRect] = []
            for section in 0..<section {
                let rect = CGRect(x: 0, y: y * CGFloat(section), width: width, height: heightPerSection)
                rects.append(rect)
            }
            return rects
        }()
        
        for section in 0..<section {
            
            let chartData = dataSource.chartView(self, chartDataInSection: section)
            let drawRectsInSection = drawRects[section]
            let barHeight: CGFloat = chartData.barWidth
            let barWidth: CGFloat = drawRectsInSection.size.width - timeDurationFrameWidth
            
            let chartLayer = CALayer()
            chartLayer.contentsScale = UIScreen.main.scale
            chartLayer.frame = drawRectsInSection
            
            // Time Duration
            let timeDurationLayer: CATextLayer = CATextLayer()
            let textLayerHeight: CGFloat = 20
            let originY: CGFloat = CGFloat(section) * drawRectsInSection.height + drawRectsInSection.height / 2 - textLayerHeight / 2
            timeDurationLayer.frame = CGRect(x: barWidth, y: originY, width: timeDurationFrameWidth, height: textLayerHeight)
            timeDurationLayer.contentsScale = UIScreen.main.scale
            timeDurationLayer.string = chartData.timeDuration
            timeDurationLayer.foregroundColor = UIColor(displayP3Red: 136/255, green: 152/255, blue: 170/255, alpha: 1.0).cgColor
            timeDurationLayer.fontSize = 17
            timeDurationLayer.alignmentMode = .center
            self.mainLayer.addSublayer(timeDurationLayer)
            
            var chartFrame = drawRectsInSection
            chartFrame.size.width = barWidth
            self.drawChart(in: chartLayer, in: chartFrame, chartData: chartData, barHeight: barHeight)
            
        }
    }
    
    private func drawChart(in layer: CALayer, in rect: CGRect, chartData: ChartData, barHeight: CGFloat) {
        
        // Main Chart
        let tuple = self.colorsLocationsAndTotalPercentage(chartData.components)
        let colors: [CGColor] = tuple.0
        let locations: [CGFloat] = tuple.1
        let totalPercentage: CGFloat = tuple.2
        
        let gradientLayer = CAGradientLayer()
        let originY = rect.size.height / 2 - barHeight / 2
        gradientLayer.frame = CGRect(x: 0, y: originY, width: rect.width, height: barHeight)
        gradientLayer.colors = colors
        gradientLayer.locations = locations.map { NSNumber(value: Float($0)) }
        gradientLayer.contentsScale = UIScreen.main.scale
        gradientLayer.cornerRadius = 10
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        
        layer.addSublayer(gradientLayer)
        self.mainLayer.addSublayer(layer)
    }
    
    override func colorsLocationsAndTotalPercentage(_ components: [ChartDataComponent]) -> ([CGColor], [CGFloat], CGFloat) {
        
        //TODO: - Set Temporary
        let maxTime: CGFloat = {
            var max: CGFloat = 0
            for comp in components {
                max += comp.data
            }
            return max
        }()
        
        var colors: [CGColor] = []
        
        var locations: [CGFloat] = [
            0.0
        ]
        
        let totalPercentage: CGFloat = {
            var total: CGFloat = 0.0
            for component in components {
                total += component.data / maxTime
            }
            return total
        }()

        var accumulationPercentage: CGFloat = 0
        
        for (index, component) in components.reversed().enumerated() {
            let percentage = component.data / maxTime
            
            locations.append(percentage + accumulationPercentage)
            
            if index + 1 < components.count {
                locations.append((percentage + accumulationPercentage))
            }
            
            accumulationPercentage += percentage
            colors.append(contentsOf: [component.color, component.color])
        }
        
        return (colors, locations, totalPercentage)
    }
    
}


protocol ChartViewDatasource: class {
    func numberOfSections(in chartView: ChartView) -> Int
    func chatrView(_ chartView: ChartView, hasSubChartInSection: Int) -> Bool
    func chartView(_ chartView: ChartView, chartDataInSection: Int) -> ChartData
}

protocol ChartData {
    
    var components: [ChartDataComponent] { get set }
    var barWidth: CGFloat { get set }
    
    var subComponents: [ChartDataComponent]? { get set }
    var subBarWidth: CGFloat? { get set }
    
    var startPeriod: String { get set }
    var endPeriod: String? { get set }
    var timeDuration: String { get set }
}

protocol ChartDataComponent {
    var data: CGFloat { get set }
    var color: CGColor { get set }
}
