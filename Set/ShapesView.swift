//
//  ShapesView.swift
//  Set
//
//  Created by Khen Cruzat on 14/12/2017.
//  Copyright © 2017 Khen Cruzat. All rights reserved.
//

import UIKit

@IBDesignable
class ShapesView: UIView {

    var colour: UIColor = UIColor.black { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    var shape: String = "diamond" { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    var shading: String = "striped" { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    
    override func draw(_ rect: CGRect) {
        var path: UIBezierPath = UIBezierPath()
        
        switch shape{
        case "diamond":
            path.move(to: CGPoint(x: 0, y: bounds.maxY/2))
            path.addLine(to: CGPoint(x: bounds.maxX/2, y:0))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY/2))
            path.addLine(to: CGPoint(x: bounds.maxX/2, y: bounds.maxY))
            path.close()
        case "oval":
            path = UIBezierPath(roundedRect: bounds, cornerRadius: 90.0)
        case "squiggle":
            path = UIBezierPath(roundedRect: bounds, cornerRadius: 50.0)
        default: break
        }
        path.lineWidth = 5.0
        path.addClip()
        colour.setStroke()
        path.stroke()
        
        switch shading{
        case "filled":
            colour.setFill()
            path.fill()
        case "striped":
            let stripes = UIBezierPath()
            let numberOfStripes = 10
            for step in 1...numberOfStripes {
                stripes.move(to: CGPoint(x: 0, y: (bounds.maxY/CGFloat(numberOfStripes)) * CGFloat(step)))
                stripes.addLine(to: CGPoint(x: bounds.maxX, y:(bounds.maxY/CGFloat(numberOfStripes)) * CGFloat(step)))
            }
            
            stripes.lineWidth = 1.0
            colour.setStroke()
            stripes.stroke()
        default: break
        }
    }    

}
