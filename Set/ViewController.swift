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
    
    var cardViewList = [CardView]()
    var selectedIndex = [Int]()
    lazy var grid: Grid = Grid(layout: .aspectRatio(CGFloat(5.0/8.0)))
    
    @IBOutlet weak var cardGrid: UIView! {
        didSet {
            grid.frame = cardGrid.bounds
            
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.dealCards(_:)))
            swipe.direction = [.down]
            cardGrid.addGestureRecognizer(swipe)
            
            let rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards))
            cardGrid.addGestureRecognizer(rotate)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        loadStartingCards()
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
        for cardView in cardViewList {
            cardView.removeFromSuperview()
        }
        cardViewList.removeAll()
        game = Set();
        loadStartingCards()
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
        if game.selectedCards.count == 3, game.matchedCards.contains(array: game.selectedCards) {
            game.touchCard(card: game.selectedCards.first!)
        } else {
            game.drawThreeCards()
        }
        updateViewFromModel()
    }

    
    private func redrawCards() {
        for (index, card) in game.faceUpCards.enumerated() {
            cardViewList[cardViewList.index(where: {$0.card! == card})!].frame = grid[index]!.insetBy(dx: 2.0, dy: 2.0)
        }
    }
    
    @objc func shuffleCards(_ sender: UIRotationGestureRecognizer){
        if sender.state == .ended {
            game.shuffleCards()
            redrawCards()
        }
    }
    
    private func loadStartingCards() {
        grid.cellCount = game.faceUpCards.count
        for (index, card) in game.faceUpCards.enumerated() {
            loadOneCard(card: card, index: index)
        }
        updateViewFromModel()
    }
    
    private func updateViewFromModel(){
        var cardList = [Card]()
        for cardView in cardViewList { cardList.append(cardView.card!)}
        let newCards = game.faceUpCards.filter { !cardList.contains($0)}
        let oldCards = cardList.filter { !game.faceUpCards.contains($0)}
        
        if grid.cellCount != game.faceUpCards.count {
            
            if grid.cellCount < game.faceUpCards.count {
                var gridCellCount = grid.cellCount
                grid.cellCount = game.faceUpCards.count
                for card in newCards {
                    loadOneCard(card: card, index: gridCellCount)
                    gridCellCount += 1
                }
            } else {
                grid.cellCount = game.faceUpCards.count
                for card in oldCards {
                    if let index = cardViewList.index(where: {$0.card! == card}){
                        let cardView = cardViewList[index]
                        cardView.removeFromSuperview()
                        cardViewList.remove(at: index)
                    }
                }
            }
        } else {
            for index in newCards.indices {
                if let oldCardIndex = cardViewList.index(where: {$0.card! == oldCards[index]}){
                    let cardView = cardViewList[oldCardIndex]
                    cardView.removeFromSuperview()
                    cardViewList.remove(at: oldCardIndex)
                    loadOneCard(card: newCards[index], index: oldCardIndex)
                }
            }
            
            
            for cardView in cardViewList {
                deselectCard(cardView: cardView)
            }
            
            var selectedCardViews = [CardView]()
            
            for card in game.selectedCards {
                if let index = cardViewList.index(where: {$0.card! == card}) {
                    let cardView = cardViewList[index]
                    selectedCardViews.append(cardView)
                    selectCard(cardView: cardView)
                }
            }
            
            if game.selectedCards.count == 3 {
                if game.checkMatch() {
                    setFound(set: selectedCardViews)
                } else {
                    setMismatch(set: selectedCardViews)
                }
            }
            
            scoreLabel.text = "Score: \(game.score)"
        }
        redrawCards()
        
    }
    
    private func loadOneCard(card: Card, index: Int){
        let cardView = CardView()
        cardView.card = card
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
        cardViewList.append(cardView)
    }
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer){
        if let cardView = sender.view as? CardView, let card = cardView.card {
            game.touchCard(card: card)
            updateViewFromModel()
        }
    }
    
    private func setFound(set: [CardView]) {
        for cardView in set{
            cardView.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    private func setMismatch(set: [CardView]) {
        for cardView in set {
            cardView.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    private func selectCard(cardView: CardView){
        cardView.layer.borderWidth = 3.0
        cardView.layer.borderColor = UIColor.orange.cgColor
        cardView.layer.cornerRadius = 8.0
    }
    
    private func deselectCard(cardView: CardView){
        cardView.layer.borderWidth = 0.0
        cardView.layer.borderColor = UIColor.clear.cgColor
        cardView.layer.cornerRadius = 1.0
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
