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
    let colours = [UIColor.red, #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), UIColor.purple]
    let shadings = ["filled", "outline", "striped"]
    
    var cardIndex = [Int:Card]()
    var cardViewIndex = [Int:CardView]()
    var selectedIndex = [Int]()
    lazy var grid: Grid = Grid(layout: .aspectRatio(CGFloat(5.0/8.0)))
    
    @IBOutlet weak var cardGrid: UIView! {
        didSet {
            loadCards()
            
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.dealCardsToGrid))
            swipe.direction = [.down]
            cardGrid.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards))
            cardGrid.addGestureRecognizer(rotate)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func rotated() {
        grid.frame = cardGrid.bounds
        redrawCards()
    }
    
    @IBOutlet weak var scoreLabel: UILabel!

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
        dealCardsToGrid()
    }
    
    @objc func dealCardsToGrid(){
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
    
    @objc func shuffleCards(_ sender: UIRotationGestureRecognizer){
        if sender.state == .ended {
            var last = cardIndex.count - 1
            
            while last > 0 {
                let rand = last.arc4random
                let tempCard = cardIndex[rand]
                let tempCardView = cardViewIndex[rand]
                cardIndex[rand] = cardIndex[last]
                cardIndex[last] = tempCard
                cardViewIndex[rand] = cardViewIndex[last]
                cardViewIndex[last] = tempCardView
                last -= 1
            }
            
            selectedIndex.removeAll()
            for card in game.selectedCards {
                if let key = cardIndex.someKey(forValue: card) {
                    selectedIndex.append(key)
                }
            }
            
            redrawCards()
        }
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCard(_:)))
        cardView.addGestureRecognizer(tap)
        cardView.isUserInteractionEnabled = true
        
        cardGrid.addSubview(cardView)
        cardViewIndex[index] = cardView
        cardIndex[index] = card
        game.faceUpCards.append(card)
    }
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer){
        let cardView = sender.view as! CardView
        
        if let cardNumber = cardViewIndex.someKey(forValue: cardView) {
            let card = cardIndex[cardNumber]!
            if selectedIndex.count == 3 {
                if game.matchedCards.contains(game.selectedCards.first!){
                    dealCardsToGrid()
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
        }
        scoreLabel.text = "Score: \(game.score)"
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

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
