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
    
    let shapes = ["diamond", "oval", "squiggle"]
    let colours = [UIColor.red, UIColor.green, UIColor.blue]
    let shadings = ["filled", "outline", "striped"]
    
    var cardIndex = [Int:Card]()
    var faceDownIndex = [Int]()
    var selectedIndex = [Int]()
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet var cardButtons: [UIButton]!{
        didSet {
            loadCardButtons()
        }
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.index(of: sender){
            print("card number \(cardNumber)")
            let card = cardIndex[cardNumber]!
            print("\(card.identifier["colour"]!), \(shadings[card.identifier["shading"]!])")
            if selectedIndex.count == 3{
                if game.matchedCards.contains(game.selectedCards.first!){
                    dealCards(sender)
                    if !game.matchedCards.contains(card){
                        selectCard(index: cardNumber)
                    }
                } else {
                    for index in selectedIndex {
                        deselectCard(index: index)
                    }
                }
            }
            else if game.selectedCards.contains(card){
                game.score -= 1
                deselectCard(index: cardNumber)
            } else if game.selectedCards.count < 3{
                selectCard(index: cardNumber)
            }
            if game.selectedCards.count == 3 {
                if game.checkMatch() {
                    setFound()
                } else {
                    setMismatch()
                }
            }
            scoreLabel.text = "Score: \(game.score)"
        }
    }

    @IBAction func newGame(_ sender: UIButton) {
        for index in selectedIndex {
            deselectCard(index: index)
        }
        game = Set();
        cardIndex.removeAll()
        faceDownIndex.removeAll()
        selectedIndex.removeAll()
        scoreLabel.text = "Score: \(game.score)"
        loadCardButtons()
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
        if game.deckCards.count > 0 {
            if game.selectedCards.count == 3, game.matchedCards.contains(game.selectedCards.first!){
                for index in selectedIndex {
                    deselectCard(index: index)
                    
                    let button = cardButtons[index]
                    let card = game.deckCards.removeFirst()
                    game.faceUpCards.append(card)
                    cardIndex[index] = card
                    
                    let identifier = card.identifier
                    let attribText = buildAttributes(identifier: identifier)
                    button.setAttributedTitle(attribText, for: UIControlState.normal)
                    button.isEnabled = true
                    button.layer.mask = nil
                    
                    
                }
                
            } else if faceDownIndex.count > 0 {
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
        } else {
            if game.selectedCards.count == 3, game.matchedCards.contains(game.selectedCards.first!) {
                for index in selectedIndex {
                    let button = cardButtons[index]
                    let layer = CAShapeLayer()
                    layer.frame = .zero
                    button.layer.mask = layer
                    button.isEnabled = false
                    deselectCard(index: index)
                }
            }
        }
        
    }
    
    private func setFound() {
        for index in selectedIndex{
            let button = cardButtons[index]
            button.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    private func setMismatch() {
        for index in selectedIndex {
                let button = cardButtons[index]
                button.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    private func selectCard(index: Int){
        let card = cardIndex[index]!
        let button = cardButtons[index]
        button.layer.borderWidth = 3.0
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.cornerRadius = 8.0
        selectedIndex.append(index)
        game.selectedCards.append(card)
        
    }
    
    private func deselectCard(index: Int){
        let card = cardIndex[index]!
        let button = cardButtons[index]
        button.layer.borderWidth = 0.0
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.cornerRadius = 1.0
        selectedIndex.remove(at: selectedIndex.index(of: index)!)
        game.selectedCards.remove(at: game.selectedCards.index(of: card)!)
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
    
    private func loadCardButtons() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            button.isEnabled = true
            button.layer.mask = nil
        }
        
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
