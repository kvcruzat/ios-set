//
//  CardView.swift
//  Set
//
//  Created by Khen Cruzat on 14/12/2017.
//  Copyright © 2017 Khen Cruzat. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    var card: SetCard?
    var isFaceUp = false { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    
    var cardSize: CGSize?
    var isInitialized = false
    
    var colour: UIColor = UIColor.red { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    var shape: String = "squiggle" { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    var amount: Int = 3 { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    var shading: String = "striped" { didSet{ setNeedsDisplay(); setNeedsLayout()}}
    
    private lazy var shapes = createShapes()

    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
    }

    private func createShapes() -> [UIView] {
        var shapeCollection = [ShapesView]()
        for _ in 1...amount {
            let shapeView = ShapesView()
            shapeView.colour = colour
            shapeView.shading = shading
            shapeView.shape = shape
            shapeView.isOpaque = false
            shapeCollection.append(shapeView)
        }

        return shapeCollection
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isInitialized, cardSize != nil {
            bounds.size = cardSize!
            cardSize = nil
            isInitialized = true
        }
        
        let shapesBounds = bounds.size.applying(CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7))
        let shapeSize = shapesBounds.applying(CGAffineTransform.identity.scaledBy(x: 1.0, y: 0.3))
        var shapeCentres = [CGPoint]()
        
        switch amount {
        case 1:
            shapeCentres.append(CGPoint(x: bounds.midX, y: bounds.midY))
        case 2:
            shapeCentres.append(CGPoint(x: bounds.midX, y: bounds.maxY/CGFloat(3)))
            shapeCentres.append(CGPoint(x: bounds.midX, y: (bounds.maxY * CGFloat(2.0/3.0))))
        case 3:
            shapeCentres.append(CGPoint(x: bounds.midX, y: bounds.maxY/CGFloat(4)))
            shapeCentres.append(CGPoint(x: bounds.midX, y: (bounds.maxY * CGFloat(2.0/4.0))))
            shapeCentres.append(CGPoint(x: bounds.midX, y: (bounds.maxY * CGFloat(3.0/4.0))))
        default:
            break
        }
        
        
        for index in 0...shapes.count-1 {
            shapes[index].isHidden = !isFaceUp
            shapes[index].frame.size = shapeSize
            shapes[index].center = shapeCentres[index]
            addSubview(shapes[index])
        }
        
    }

    
}
