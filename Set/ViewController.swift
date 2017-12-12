//
//  ViewController.swift
//  Set
//
//  Created by Khen Cruzat on 11/12/2017.
//  Copyright © 2017 Khen Cruzat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var game = Set()
    
    let shapes = ["▲", "●", "■"]
    let colours = [UIColor.red, UIColor.green, UIColor.blue]
    let shadings = ["filled", "outline", "striped"]
    
    var cardIndex = [Int:Card]()
    var faceDownIndex = [Int]()
    
    @IBOutlet var cardButtons: [UIButton]!{
        didSet {
            var cardArray: [Int] = Array(0...cardButtons.count-1)
            
            var last = cardArray.count - 1

            while last > 0 {
                let rand = Int(arc4random_uniform(UInt32(last)))
                cardArray.swapAt(last, rand)
                last -= 1
            }
            
            while game.faceUpCards.count < 12{
                let index = cardArray.removeFirst()
            
                let card = game.deckCards.removeFirst()
                game.faceUpCards.append(card)
                
                let button = cardButtons[index]
                let identifier = card.identifier
                let attribText = buildAttributes(identifier: identifier)
                button.setAttributedTitle(attribText, for: UIControlState.normal)
                
                cardIndex[index] = card
            }
            for index in cardArray {
                let button = cardButtons[index]
                let layer = CAShapeLayer()
                layer.frame = .zero
                button.layer.mask = layer
                button.isEnabled = false
            }
            faceDownIndex = cardArray
        }
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.index(of: sender){
            print("card number \(cardNumber)")
            let card = cardIndex[cardNumber]!
            print("\(card.identifier["colour"]!), \(shadings[card.identifier["shading"]!])")
            if game.selectedCards.contains(card){
                deselectCard(index: cardNumber)
                game.selectedCards.remove(at: game.selectedCards.index(of: card)!)
            } else if game.selectedCards.count < 3{
                selectCard(index: cardNumber)
                game.selectedCards.append(card)
            }
            if game.selectedCards.count == 3 {
                if game.checkMatch() { print("isMatch")}
                else { print("notMatch")}
            }
        }
    }

    @IBAction func newGame(_ sender: UIButton) {
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
        if faceDownIndex.count > 0 {
            for _ in 1...3 {
                let index = faceDownIndex.removeFirst()
                let card = game.deckCards.removeFirst()
                game.faceUpCards.append(card)
                cardIndex[index] = card
                
                let button = cardButtons[index]
                let identifier = card.identifier
                let attribText = buildAttributes(identifier: identifier)
                button.setAttributedTitle(attribText, for: UIControlState.normal)
                button.isEnabled = true
                button.layer.mask = nil
            }
        }
    }
    
    private func selectCard(index: Int){
        let button = cardButtons[index]
        button.layer.borderWidth = 3.0
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 8.0
    }
    
    private func deselectCard(index: Int){
        let button = cardButtons[index]
        button.layer.borderWidth = 0.0
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.cornerRadius = 1.0
    }
    
    private func buildAttributes(identifier: [String:Int]) -> NSAttributedString{
        var attributes: [NSAttributedStringKey : Any] = [
            .strokeColor : colours[identifier["colour"]!],
            .strokeWidth : -5.0
        ]
        
        switch shadings[identifier["shading"]!] {
        case "filled":
            attributes[.foregroundColor] = colours[identifier["colour"]!].withAlphaComponent(1.0)
            attributes[.strokeWidth] = -5.0
        case "striped":
            attributes[.foregroundColor] = colours[identifier["colour"]!].withAlphaComponent(0.20)
        case "outline":
            attributes[.strokeWidth] = 5.0
        default:
            print("Error shading not found")
        }
        
        let buttonTitle = String(repeating: shapes[identifier["shape"]!], count: identifier["amount"]!)
        return NSAttributedString(string: buttonTitle, attributes: attributes)
    }

}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
