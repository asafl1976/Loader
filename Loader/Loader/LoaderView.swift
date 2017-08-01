//
//  MessageView.swift
//  Messages
//
//  Created by ASAF LEVY on 02/06/2017.
//  Copyright © 2017 ASAF LEVY. All rights reserved.
//

import UIKit


class LoaderView: UIView {
    
    fileprivate var outerCircleLayer:LoaderArcLayer?
    fileprivate var innerCircleLayer:LoaderArcLayer?
    fileprivate var loaderCheckLayer:LoaderCheckLayer?
    
    var circleTime: Double = 2.0
    var innerCicleLineWidth: CGFloat = 2.0
    var outerCicleLineWidth: CGFloat = 3.0

    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    override init (frame : CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let outerCicleFrame = bounds
        outerCircleLayer = LoaderArcLayer(frame: outerCicleFrame)
        outerCircleLayer?.add(createRotateClockWiseAnimation(), forKey: "rotationAnimation")
        outerCircleLayer?.lineWidth = 2
        layer.addSublayer(outerCircleLayer!)

        let innerCircleGap:CGFloat = 16.0
        let innerCircleFrame = CGRect(x: innerCircleGap/2, y: innerCircleGap/2, width: outerCicleFrame.size.width - innerCircleGap, height: outerCicleFrame.size.height - innerCircleGap)
        innerCircleLayer = LoaderArcLayer(frame: innerCircleFrame)
    //    innerCircleLayer?.add(createRotateCounterClockWiseAnimation(), forKey: "rotationAnimation")
        innerCircleLayer?.lineWidth = 2
        //layer.addSublayer(innerCircleLayer!)
    
        let checkFrame = CGRect(x: innerCircleGap/2, y: innerCircleGap/2, width: outerCicleFrame.size.width - innerCircleGap, height: outerCicleFrame.size.height - innerCircleGap)
        loaderCheckLayer = LoaderCheckLayer(frame: outerCicleFrame)
        loaderCheckLayer?.lineWidth = innerCircleLayer!.lineWidth
        layer.addSublayer(loaderCheckLayer!)
        

    }
    

    fileprivate func setupView() {
        backgroundColor = UIColor.clear
    }

    
    fileprivate func createRotateClockWiseAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = -2*Double.pi
        animation.duration = self.circleTime
        animation.repeatCount = Float.infinity
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        return animation
    }
    
    fileprivate func createRotateCounterClockWiseAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = 2*Double.pi
        animation.duration = self.circleTime
        animation.repeatCount = Float.infinity
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        return animation
    }
    
    fileprivate  func closePathAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.duration = self.circleTime
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        return animation
    }
    
    fileprivate  func fadeAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.toValue = 0
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.isRemovedOnCompletion = false
        return animation
    }
 
    func closeOutterPath(duration:CFTimeInterval) {
        outerCircleLayer?.closePathAnimated(duration: duration)
    }
    
    func completeLoading(_ success: Bool) {
        loaderCheckLayer?.showCheckAnimated(duration: 0.3)
        innerCircleLayer?.fadeOutAnimated(duration: 0.2)
        outerCircleLayer?.closePathAnimated(duration: 0.7*0.3)
    }
   
}


class LoaderCheckLayer: CAShapeLayer {
    fileprivate let checkLayer = CAShapeLayer()
    
    override var lineWidth: CGFloat {
        didSet {
            print(lineWidth)
            checkLayer.lineWidth = lineWidth
        }
    }
    
    var lineColor:UIColor = UIColor.black {
        didSet {
            checkLayer.strokeColor = lineColor.cgColor
        }
    }
    
    init(frame:CGRect) {
        super.init()
        self.frame = frame
        checkLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        checkLayer.fillColor = nil
        checkLayer.lineCap = kCALineCapRound
        checkLayer.strokeColor = UIColor.red.cgColor
        addSublayer(checkLayer)
        
        setStrokeSuccessShapePath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setStrokeSuccessShapePath() {
        let width = self.bounds.width
        let height = self.bounds.height
        let square = min(width, height)
        let b = square/2
        let oneTenth = square/10
        let xOffset = oneTenth
        let yOffset = 1.5 * oneTenth
        let ySpace = 3.2 * oneTenth
        let point = correctJoinPoint()
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: point.x, y: point.y))
        path.addLine(to: CGPoint(x: b - xOffset, y: b + yOffset))
        path.addLine(to: CGPoint(x: 2 * b - xOffset + yOffset - ySpace, y: ySpace))
        
        checkLayer.strokeColor = UIColor.black.cgColor
        checkLayer.path = path
        checkLayer.cornerRadius = square/2
        checkLayer.masksToBounds = true
        checkLayer.strokeStart = 0.0
        checkLayer.strokeEnd = 0.0
    }
    
    fileprivate func correctJoinPoint() -> CGPoint {
        let r = min(self.bounds.width, self.bounds.height)/2
        let m = r/2
        let k = lineWidth/2
        
        let a: CGFloat = 2.0
        let b = -4 * r + 2 * m
        let c = (r - m) * (r - m) + 2 * r * k - k * k
        let x = (-b - sqrt(b * b - 4 * a * c))/(2 * a)
        let y = x + m
        
        return CGPoint(x: x, y: y)
    }
    
    func showCheckAnimated(duration:CFTimeInterval) {

        let duration = 0.9
        let timeFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let phase2StrokeStartAnimation = CASpringAnimation(keyPath: "strokeStart")
        phase2StrokeStartAnimation.fromValue = 0.0
        phase2StrokeStartAnimation.toValue = 0.25
        phase2StrokeStartAnimation.duration = duration
        phase2StrokeStartAnimation.timingFunction = timeFunction

        let phase2StrokeEndAnimation = CASpringAnimation(keyPath: "strokeEnd")
        phase2StrokeEndAnimation.fromValue = 0.0
        phase2StrokeEndAnimation.toValue = 1.0
        phase2StrokeEndAnimation.duration = duration
        phase2StrokeEndAnimation.timingFunction = timeFunction
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [phase2StrokeStartAnimation, phase2StrokeEndAnimation]
        groupAnimation.duration =  duration
        groupAnimation.delegate = self
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeForwards
        checkLayer.add(groupAnimation, forKey: nil)
    }
}

extension LoaderCheckLayer:CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool)  {
      //  checkLayer.strokeEnd = 1.0
      //  checkLayer.strokeStart = 0.25
    }
}



class LoaderArcLayer: CAShapeLayer {
    let arcLayer1 = CAShapeLayer()
    let arcLayer2 = CAShapeLayer()
    
    override var lineWidth: CGFloat {
        didSet {
            arcLayer1.lineWidth = lineWidth
            arcLayer2.lineWidth = lineWidth
        }
    }
    
    var lineColor:UIColor = UIColor.black {
        didSet {
            arcLayer1.strokeColor = lineColor.cgColor
            arcLayer2.strokeColor = lineColor.cgColor
        }
    }
    
    init(frame:CGRect) {
        super.init()
        self.frame = frame
        let center = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
        //self.position = center
        let radius = min(frame.size.width, frame.size.height)/2.0 - lineWidth/2.0

        //Create outer arcs
        let outerArcPath1 = UIBezierPath()
        outerArcPath1.addArc(withCenter: center, radius: radius, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(3*Double.pi), clockwise: true)
        arcLayer1.path = outerArcPath1.cgPath
        arcLayer1.fillColor = nil
        arcLayer1.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        arcLayer1.lineWidth = lineWidth
        arcLayer1.lineCap = kCALineCapRound
        arcLayer1.strokeStart = 0.0
        arcLayer1.strokeEnd = 0.2
        arcLayer1.strokeColor = lineColor.cgColor
        
        let outerArcPath2 = UIBezierPath()
        outerArcPath2.addArc(withCenter: center, radius: radius, startAngle: CGFloat(3*Double.pi/2), endAngle: CGFloat(Double.pi/2), clockwise: true)
        arcLayer2.path = outerArcPath2.cgPath
        arcLayer2.fillColor = nil
        arcLayer2.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        arcLayer2.lineWidth = lineWidth
        arcLayer2.lineCap = kCALineCapRound
        arcLayer2.strokeStart = 0.0
        arcLayer2.strokeEnd = 0.5
        arcLayer2.strokeColor = lineColor.cgColor
        
        addSublayer(arcLayer1)
        //addSublayer(arcLayer2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closePathAnimated(duration:CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        arcLayer1.add(animation, forKey: "strokeEnd")
        arcLayer2.add(animation, forKey: "strokeEnd")
    }
    
    fileprivate  func fadeOutAnimated(duration:CFTimeInterval) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.toValue = 0
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        arcLayer1.add(animation, forKey: "opacity")
        arcLayer2.add(animation, forKey: "opacity")
    }

}


