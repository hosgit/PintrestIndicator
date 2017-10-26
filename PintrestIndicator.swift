//
//  File.swift
//  PintrestIndictor
//
//  Created by Hos on 25/10/17.
//  Copyright © 2017 Hos. All rights reserved.
//

//MIT License
//
//Copyright (c) 2017 I Code
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.



import UIKit

struct MyColors
{
    static let backgroundColor = UIColor(displayP3Red: 120/255, green: 120/255, blue: 120/255, alpha: 1).cgColor
    static let ringColor = UIColor.init(white: 1, alpha: 1.0).cgColor
    static let internalColor = UIColor.clear.cgColor
}

struct Defaults
{
    static let mainRadius = 22.0
    static let internalRadius = 9.0
    static let ringRadius = 2.5
}


class BaseLayer: CAShapeLayer
{
    init(position:CGPoint,radius:Double ,color:CGColor = MyColors.backgroundColor)
    {
        super.init()
        self.position = position
        configureMe(color:color,path:getMyPath(center: position, radius:radius))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func configureMe(color:CGColor,path:CGPath)
    {
        self.strokeColor = color
        self.fillMode = kCAFillModeForwards
        self.fillColor = strokeColor
        self.bounds = path.boundingBox
        self.path = path
    }
}

class PintrestIndicator:BaseLayer
{
    var center = CGPoint(x: 0, y: 0)
    private var ringPoints = [CGPoint]()
    private var rings = [BaseLayer]()
    lazy var internalLayer:BaseLayer =
        {
            let layer = BaseLayer(position: center, radius: Defaults.internalRadius,color:MyColors.internalColor)
            return layer
    }()
    
    override init(position: CGPoint, radius: Double = Defaults.mainRadius, color: CGColor = MyColors.backgroundColor)
    {
        super.init(position: position, radius: radius, color: color)
        center = position
        self.addInternalLayer()
        addRings()
    }
    
    internal required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
    }
    func  addInternalLayer()
    {
        self.addSublayer(internalLayer)
    }
    
    func calculateRingPoints()
    {
        for current in 0...3
        {
            let x  = center.x  +  CGFloat(Defaults.internalRadius  * cos(Double.pi * 2 +  ( Double(current) * Double.pi / 2)))
            let y  = center.y  +  CGFloat(Defaults.internalRadius  * sin(Double.pi * 2 +  ( Double(current) * Double.pi / 2)))
            let point = CGPoint(x: x, y: y)
            ringPoints.append(point)
        }
    }
    
    func  addRings()
    {
        calculateRingPoints()
        for index in 0...3
        {
            let ringPosition = ringPoints[index]
            let ring = Ring(position: ringPosition, radius: Defaults.ringRadius)
            rings.append(ring)
            internalLayer.addSublayer(ring)
        }
      rotationAnimation()
    }
    
    func  rotationAnimation()
    {
        let animation = CABasicAnimation()
        animation.keyPath = "transform.rotation"
        animation.fromValue = 0.0
        animation.toValue = CGFloat(Double.pi * 2)
        animation.duration = 0.7
        animation.repeatCount = HUGE
        internalLayer.add(animation, forKey: "rotation")
    }
}



class Ring:BaseLayer
{
    override init(position: CGPoint, radius: Double, color: CGColor = MyColors.ringColor)
    {
        super.init(position: position, radius: radius, color:color)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}


extension CAShapeLayer
{
    func getMyPath(center:CGPoint,radius:Double)-> CGPath
    {
        let path =  UIBezierPath()
        path.addArc(withCenter: center,
                    radius: CGFloat(radius),
                    startAngle: 0,
                    endAngle: CGFloat(Double.pi  * 2),
                    clockwise: true)
        
        return path.cgPath
    }
    
   static func  animateAlongThePath(path:CGPath)-> CAAnimation
    {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.path = path
        animation.duration = 10
        animation.isAdditive = true
        animation.repeatCount = HUGE
        animation.calculationMode = kCAAnimationPaced
        return animation
    }
    
}
