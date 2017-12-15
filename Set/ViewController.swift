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
    
    var cardIndex = [(cardView: CardView, card: Card)]()
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
        for (_, cardTuple) in cardIndex.enumerated() {
            cardTuple.cardView.removeFromSuperview()
        }
        game = Set();
        cardIndex.removeAll()
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
                    cardIndex[index].cardView.removeFromSuperview()
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
                while selectedIndex.count > 0 {
                    let index = selectedIndex.first!
                    cardIndex[index].cardView.removeFromSuperview()
                    deselectCard(index: index)
                    cardIndex.remove(at: index)
                    recheckSelectedCards()
                }
                grid.cellCount -= 3
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
                cardIndex[rand] = cardIndex[last]
                cardIndex[last] = tempCard
                last -= 1
            }
            
            selectedIndex.removeAll()
            for selectedCard in game.selectedCards {
                for (index, cardTuple) in cardIndex.enumerated() {
                    if selectedCard == cardTuple.card {
                        selectedIndex.append(index)
                    }
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
        for index in cardIndex.indices{
            cardIndex[index].cardView.frame = grid[index]!.insetBy(dx: 2.0, dy: 2.0)
            cardIndex[index].cardView.setNeedsDisplay()
            cardIndex[index].cardView.setNeedsLayout()
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
        if index < cardIndex.count - 1 { cardIndex[index] = (cardView, card) }
        else { cardIndex.append((cardView, card))}
        game.faceUpCards.append(card)
    }
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer){
        let cardView = sender.view as! CardView
        
        var card: Card?
        var cardNumber: Int?
        
        for (index, cardTuple) in cardIndex.enumerated() {
            if cardView == cardTuple.cardView {
                card = cardTuple.card
                cardNumber = index
            }
        }
        
        
        if card != nil, cardNumber != nil{
            if selectedIndex.count == 3 {
                if game.matchedCards.contains(game.selectedCards.first!){
                    dealCardsToGrid()
                    if !game.matchedCards.contains(card!){
                        selectCard(index: cardNumber!)
                    }
                } else {
                    for index in selectedIndex {
                        deselectCard(index: index)
                    }
                }
            }
            else if game.selectedCards.contains(card!){
                game.score -= 1
                deselectCard(index: cardNumber!)
            } else if game.selectedCards.count < 3{
                selectCard(index: cardNumber!)
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
            cardIndex[index].cardView.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    private func setMismatch() {
        for index in selectedIndex {
            cardIndex[index].cardView.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    private func selectCard(index: Int){
        let card = cardIndex[index].card
        let cardView = cardIndex[index].cardView
        cardView.layer.borderWidth = 3.0
        cardView.layer.borderColor = UIColor.orange.cgColor
        cardView.layer.cornerRadius = 8.0
        selectedIndex.append(index)
        game.selectedCards.append(card)
        
    }
    
    private func deselectCard(index: Int){
        let card = cardIndex[index].card
        let cardView = cardIndex[index].cardView
        cardView.layer.borderWidth = 0.0
        cardView.layer.borderColor = UIColor.clear.cgColor
        cardView.layer.cornerRadius = 1.0

        selectedIndex.remove(at: selectedIndex.index(of: index)!)
        game.selectedCards.remove(at: game.selectedCards.index(of: card)!)
    }
    
    private func recheckSelectedCards() {
        selectedIndex.removeAll()
        for card in game.selectedCards {
            for (index, cardTuple) in cardIndex.enumerated() {
                if cardTuple.card == card {
                    selectedIndex.append(index)
                }
            }
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

