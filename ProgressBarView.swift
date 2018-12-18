//
//  ProgressBarView.swift
//  queue
//
//  Created by Joseph Jordan on 12/11/18.
//  Copyright © 2018 queue. All rights reserved.
//

import UIKit

class ProgressBarView: UIView {
    
    var bgPath: UIBezierPath!
    var shapeLayer: CAShapeLayer!
    var progressLayer: CAShapeLayer!
    let lineWidth : CGFloat = 3.5
    
    private func createCirclePath() {
        let x = self.frame.width/2
        let y = self.frame.height/2
        let center = CGPoint(x: x, y: y)
        bgPath = UIBezierPath()
        bgPath.addArc(withCenter: center, radius: x, startAngle: CGFloat(0), endAngle: 2 * CGFloat.pi, clockwise: true)
        bgPath.close()
    }
    
    
    
    func simpleShape() {
        createCirclePath()
        shapeLayer = CAShapeLayer()
        shapeLayer.path = bgPath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        progressLayer = CAShapeLayer()
        progressLayer.path = bgPath.cgPath
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.fillColor = nil
        progressLayer.strokeColor = Data.defaultBlue.cgColor
        progressLayer.strokeEnd = 0.0
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(progressLayer)
        self.transform = self.transform.rotated(by: CGFloat.pi / -2)
    }
    
    var progress: Float = 0 {
        willSet(newValue)
        {
            progressLayer.strokeEnd = CGFloat(newValue)
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    

}
