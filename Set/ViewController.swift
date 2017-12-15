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
    var cardViewIndex = [Int:CardView]()
    var selectedIndex = [Int]()
    lazy var grid: Grid = Grid(layout: .aspectRatio(CGFloat(5.0/8.0)))
    
    @IBOutlet weak var cardGrid: UIView! {
        didSet {
            loadCards()
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    
//    @IBAction func touchCard(_ sender: UIButton) {
//        if let cardNumber = cardButtons.index(of: sender){
//            print("card number \(cardNumber)")
//            let card = cardIndex[cardNumber]!
//            print("\(card.identifier["colour"]!), \(shadings[card.identifier["shading"]!])")
//            if selectedIndex.count == 3{
//                if game.matchedCards.contains(game.selectedCards.first!){
//                    dealCards(sender)
//                    if !game.matchedCards.contains(card){
//                        selectCard(index: cardNumber)
//                    }
//                } else {
//                    for index in selectedIndex {
//                        deselectCard(index: index)
//                    }
//                }
//            }
//            else if game.selectedCards.contains(card){
//                game.score -= 1
//                deselectCard(index: cardNumber)
//            } else if game.selectedCards.count < 3{
//                selectCard(index: cardNumber)
//            }
//            if game.selectedCards.count == 3 {
//                if game.checkMatch() {
//                    setFound()
//                } else {
//                    setMismatch()
//                }
//            }
//            scoreLabel.text = "Score: \(game.score)"
//        }
//    }

    @IBAction func newGame(_ sender: UIButton) {
        for index in selectedIndex {
            deselectCard(index: index)
        }
        for index in 0...cardViewIndex.count-1{
            if let cardView = cardViewIndex[index] {
                cardView.removeFromSuperview()
            }
        }
        game = Set();
        cardIndex.removeAll()
        cardViewIndex.removeAll()
        selectedIndex.removeAll()
        scoreLabel.text = "Score: \(game.score)"
        loadCards()
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
        if game.deckCards.count > 0 {
            if game.selectedCards.count == 3, game.matchedCards.contains(game.selectedCards.first!){
                for index in selectedIndex {
                    deselectCard(index: index)
                    cardViewIndex[index]?.removeFromSuperview()
                    loadOneCard(index: index)
                }
            } else{
                grid.cellCount += 3
                for _ in 1...3 {
                    loadOneCard(index: game.faceUpCards.count)
                }
            }
        } else {
            if game.selectedCards.count == 3, game.matchedCards.contains(game.selectedCards.first!) {
                grid.cellCount -= 3
                for index in selectedIndex {
                    if let cardView = cardViewIndex[index] {
                        cardView.removeFromSuperview()
                    }
                    deselectCard(index: index)
                }
            }
        }
        redrawCards()
        
    }
    
    private func loadCards(){
        grid.frame = cardGrid.bounds
        grid.cellCount = 12
    
        for index in 0...grid.cellCount-1 {
            loadOneCard(index: index)
        }
    }
    
    private func redrawCards() {
        for index in 0...cardViewIndex.count-1 {
            cardViewIndex[index]!.frame = grid[index]!.insetBy(dx: 2.0, dy: 2.0)
            cardViewIndex[index]!.setNeedsDisplay()
            cardViewIndex[index]!.setNeedsLayout()
        }
    }
    
    private func loadOneCard(index: Int) {
        let cardView = CardView()
        let card = game.deckCards.removeFirst()
        cardView.isOpaque = false
        cardView.colour = colours[card.identifier["colour"]!]
        cardView.shape = shapes[card.identifier["shape"]!]
        cardView.amount = card.identifier["amount"]!
        cardView.shading = shadings[card.identifier["shading"]!]
        cardView.frame = grid[index]!.insetBy(dx: 2.0, dy: 2.0)
        cardGrid.addSubview(cardView)
        cardViewIndex[index] = cardView
        cardIndex[index] = card
        game.faceUpCards.append(card)
        
    }
    
    private func setFound() {
        for index in selectedIndex{
            if let cardView = cardViewIndex[index] {
                cardView.layer.borderColor = UIColor.green.cgColor
            }
        }
    }
    
    private func setMismatch() {
        for index in selectedIndex {
            if let cardView = cardViewIndex[index] {
                cardView.layer.borderColor = UIColor.red.cgColor
            }
        }
    }
    
    private func selectCard(index: Int){
        let card = cardIndex[index]!
        if let cardView = cardViewIndex[index] {
            cardView.layer.borderWidth = 3.0
            cardView.layer.borderColor = UIColor.orange.cgColor
            cardView.layer.cornerRadius = 8.0
            selectedIndex.append(index)
            game.selectedCards.append(card)
        }
        
    }
    
    private func deselectCard(index: Int){
        let card = cardIndex[index]!
        if let cardView = cardViewIndex[index] {
            cardView.layer.borderWidth = 0.0
            cardView.layer.borderColor = UIColor.clear.cgColor
            cardView.layer.cornerRadius = 1.0
            selectedIndex.remove(at: selectedIndex.index(of: index)!)
            game.selectedCards.remove(at: game.selectedCards.index(of: card)!)
        }
        
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
