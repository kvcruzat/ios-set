//
//  ViewController.swift
//  Set
//
//  Created by Khen Cruzat on 11/12/2017.
//  Copyright © 2017 Khen Cruzat. All rights reserved.
//

import UIKit

class SetViewController: UIViewController {
    
    lazy var game = Set()
    
    let shapes = ["diamond", "oval", "squiggle"]
    let colours = [UIColor.red, #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), UIColor.purple]
    let shadings = ["filled", "outline", "striped"]
    
    var swipe: UISwipeGestureRecognizer?
    var rotate: UIRotationGestureRecognizer?
    var cardViewSize: CGSize?
    
    var cardViewList = [CardView]()
    var selectedIndex = [Int]()
    var hiScore = 0  {
        didSet {
            UserDefaults.standard.set(hiScore, forKey: "Score")
            hiScoreLabel.text = "Hi-Score: \(hiScore)"
        }
    }
    lazy var grid: Grid = Grid(layout: .aspectRatio(Constants.cardRatio))
    
    private lazy var animator = UIDynamicAnimator(referenceView: cardGrid)
    private lazy var cardBehaviour = CardBehaviour(in: animator)
    
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var numberOfSetsLabel: UILabel!
    @IBOutlet weak var hiScoreLabel: UILabel! {
        didSet {
            let defaults = UserDefaults.standard
            if defaults.object(forKey: "Score") != nil {
                hiScore = defaults.integer(forKey: "Score")
            } else { hiScore = 0 }
        }
    }
    
    @IBOutlet weak var cardGrid: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(_:)))
        swipe?.direction = [.up]
        
        rotate = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCards))
        
        grid.frame = cardGrid.bounds
        
        loadStartingCards()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func rotated() {
        redrawCards()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if grid.frame != cardGrid.bounds {
            redrawCards()
        }
    }
    
    @objc func swiped(_ sender: UISwipeGestureRecognizer){
        if sender.state == .ended {
            removeGestures()
            dealCards(sender)
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!

    @IBAction func newGame(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "There are \(game.availableSets) possible sets left. Are you sure you want to start a new game?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { action in
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            self.removeGestures()
            for cardView in self.cardViewList {
                cardView.removeFromSuperview()
            }
            self.cardViewList.removeAll()
            if self.game.score > self.hiScore { self.hiScore = self.game.score }
            self.game = Set();
            self.scoreLabel.text = "Score: \(self.game.score)"
            self.numberOfSetsLabel.text = "\(self.game.matchedCards.count/3) Sets"
            self.dealButton.backgroundColor = UIColor.lightGray
            self.dealButton.isEnabled = true
            self.loadStartingCards()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func dealCards(_ sender: Any) {
        if game.selectedCards.count == 3, game.matchedCards.contains(array: game.selectedCards) {
            game.touchCard(card: game.selectedCards.first!)
        } else {
            game.drawThreeCards()
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.game.numberOfSetsAvailable()
        }

        updateViewFromModel()
    }

    
    private func redrawCards() {
        grid.frame = cardGrid.bounds
        var tempCardViews = cardViewList
        for (index, card) in game.faceUpCards.enumerated() {
            if let cardIndex = cardViewList.index(where: {$0.card == card}) {
                tempCardViews[index] = cardViewList[cardIndex]
                let cardView = cardViewList[cardIndex]
                let newFrame = grid[index]!.insetBy(dx: 2.0, dy: 2.0)
                let cardScale = newFrame.width / cardView.bounds.width
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.4,
                    delay: 0,
                    options: [],
                    animations: {
                        cardView.transform = CGAffineTransform.identity.scaledBy(x: cardScale, y: cardScale)
                        cardView.frame = newFrame
                    },
                    completion: { finished in
                        if index == self.game.faceUpCards.indices.last! {
                            self.addGestures()
                        }
                })
            }
        }
        cardViewList = tempCardViews
    }
    
    @objc func shuffleCards(_ sender: UIRotationGestureRecognizer){
        if sender.state == .ended {
            removeGestures()
            game.shuffleCards()
            redrawCards()
        }
    }
    
    private func loadStartingCards() {
        dealButton.isEnabled = false
        grid.cellCount = game.faceUpCards.count
        cardViewSize = grid[0]?.insetBy(dx: 2.0, dy: 2.0).size
        for (index, card) in game.faceUpCards.enumerated() {
            _ = loadOneCard(card: card, index: index)
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.game.numberOfSetsAvailable()
        }
        
        for (index, cardView) in cardViewList.enumerated() {
            let cardScale = grid[0]!.insetBy(dx: 2.0, dy: 2.0).width / cardView.bounds.width
            
//            cardView.frame.size = cardView.frame.size.applying(CGAffineTransform.identity.scaledBy(x: Constants.matchCardAnimationScaleDown, y: Constants.matchCardAnimationScaleDown))
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Constants.drawCardAnimationDuration,
                delay: 0.2 + (Double(index)*0.2),
                options: [.curveEaseInOut],
                animations: {
                    cardView.transform = CGAffineTransform.identity.scaledBy(x: cardScale, y: cardScale)
                    cardView.frame = (self.grid[index]?.insetBy(dx: 2.0, dy: 2.0))!
                    cardView.alpha = 1
                    },
                completion: { position in
                    UIView.transition(with: cardView, duration: Constants.flipCardAnimationDuration, options: [.transitionFlipFromLeft] , animations: {
                        cardView.isFaceUp = true },
                        completion: { finished in
                            if index == self.cardViewList.indices.last! {
                                self.dealButton.isEnabled = true
                                self.addGestures()
                                NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
                            }
                        })
                    })
        }
    }
    
    private func updateViewFromModel(){
        var cardList = [SetCard]()
        for cardView in cardViewList { cardList.append(cardView.card!)}
        let newCards = game.faceUpCards.filter { !cardList.contains($0)}
        let oldCards = cardList.filter { !game.faceUpCards.contains($0)}
        
        if grid.cellCount != game.faceUpCards.count {
            
            if grid.cellCount < game.faceUpCards.count {
                var gridCellCount = grid.cellCount
                grid.cellCount = game.faceUpCards.count
                self.dealButton.isEnabled = false
                redrawCards()
                var newCardViews = [CardView]()
                for card in newCards {
                    newCardViews.append(loadOneCard(card: card, index: gridCellCount))
                    gridCellCount += 1
                }
                for (index, cardView) in newCardViews.enumerated() {
                    let cardScale = grid[(gridCellCount-3)+index]!.insetBy(dx: 2.0, dy: 2.0).width / cardView.bounds.width
//                    cardView.frame.size = cardView.frame.size.applying(CGAffineTransform.identity.scaledBy(x: Constants.matchCardAnimationScaleDown, y: Constants.matchCardAnimationScaleDown))
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: Constants.drawCardAnimationDuration,
                        delay: 0.2 + (Double(index)*0.2),
                        options: [.curveEaseInOut],
                        animations: {
                            cardView.transform = CGAffineTransform.identity.scaledBy(x: cardScale, y: cardScale)
                            cardView.frame = (self.grid[(gridCellCount-3)+index]?.insetBy(dx: 2.0, dy: 2.0))!
                            cardView.alpha = 1
                    },
                        completion: { position in
                            UIView.transition(with: cardView, duration: Constants.flipCardAnimationDuration, options: [.transitionFlipFromLeft] , animations: {
                                cardView.isFaceUp = true
                                if self.game.deckCards.count == 0 {
                                    self.dealButton.backgroundColor = UIColor.clear
                                    self.dealButton.isEnabled = false
                                }
                            }, completion: { finished in
                                if index == newCardViews.indices.last! {
                                    self.redrawCards()
                                    self.dealButton.isEnabled = true
                                }
                            })
                    })
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
                redrawCards()
            }
        } else {
            for index in newCards.indices {
                if let oldCardIndex = cardViewList.index(where: {$0.card! == oldCards[index]}){
                    let cardView = cardViewList[oldCardIndex]
                    cardView.removeFromSuperview()
                    let newCardView = loadOneCard(card: newCards[index], index: oldCardIndex)
                    let cardScale = grid[oldCardIndex]!.insetBy(dx: 2.0, dy: 2.0).width / newCardView.bounds.width
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: Constants.drawCardAnimationDuration,
                        delay: 0.2 + (Double(index)*0.2),
                        options: [.curveEaseInOut],
                        animations: {
                            newCardView.transform = CGAffineTransform.identity.scaledBy(x: cardScale, y: cardScale)
                            newCardView.frame = self.grid[oldCardIndex]!.insetBy(dx: 2.0, dy: 2.0)
                            newCardView.alpha = 1
                    },
                        completion: { position in
                            UIView.transition(with: newCardView, duration: Constants.flipCardAnimationDuration, options: [.transitionFlipFromLeft] , animations: {
                                newCardView.isFaceUp = true
                                if self.game.deckCards.count == 0 {
                                    self.dealButton.backgroundColor = UIColor.clear
                                    self.dealButton.isEnabled = false
                                }
                            }, completion: { finished in
                                if index == newCards.indices.last! {
                                    self.redrawCards()
                                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                                        self?.game.numberOfSetsAvailable()
                                    }
                                }
                            })
                    })
                }
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
            
            scoreLabel.text = "Score: \(game.score)"
            
            let setsAmount = game.matchedCards.count/3
            if setsAmount == 1 {
                numberOfSetsLabel.text = "\(game.matchedCards.count/3) Set"
            } else {
                numberOfSetsLabel.text = "\(game.matchedCards.count/3) Sets"
            }
            
            if game.selectedCards.count == 3 {
                if game.checkSelectedCards() {
                    setFound(set: selectedCardViews)
                } else {
                    setMismatch(set: selectedCardViews)
                }
            }
//        redrawCards()
        
    }
    
    private func loadOneCard(card: SetCard, index: Int) -> CardView{
        let cardView = CardView()
        cardView.card = card
        cardView.isOpaque = false
        cardView.cardSize = cardViewSize!
        cardView.colour = colours[card.identifier["colour"]!]
        cardView.shape = shapes[card.identifier["shape"]!]
        cardView.amount = card.identifier["amount"]!
        cardView.shading = shadings[card.identifier["shading"]!]
        cardView.bounds.size = cardViewSize!
//        cardView.frame.size = cardViewSize!
        
        cardView.center = dealButton.center
        cardView.alpha = 0

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedCard(_:)))
        cardView.addGestureRecognizer(tap)
        cardView.isUserInteractionEnabled = true

        cardGrid.addSubview(cardView)
        if cardViewList.indices.contains(index) {
            cardViewList[index] = cardView
        } else { cardViewList.append(cardView) }
        
        cardView.transform = CGAffineTransform.identity.scaledBy(x: Constants.matchCardAnimationScaleDown, y: Constants.matchCardAnimationScaleDown)
        
//        cardView.frame.size = cardView.frame.size.applying(CGAffineTransform.identity.scaledBy(x: Constants.matchCardAnimationScaleDown, y: Constants.matchCardAnimationScaleDown))
        cardView.center = dealButton.center
        return cardView
    }
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer){
        if let cardView = sender.view as? CardView, let card = cardView.card {
            game.touchCard(card: card)
            updateViewFromModel()
        }
    }
    
    private func setFound(set: [CardView]) {
        
        removeGestures()
        self.cardGrid.isUserInteractionEnabled = false
        self.dealButton.isUserInteractionEnabled = false
        
        for (index, cardView) in set.enumerated(){
            cardView.layer.borderColor = UIColor.green.cgColor
            cardView.superview?.bringSubview(toFront: cardView)
            
            cardBehaviour.addItem(cardView)
            
            Timer.scheduledTimer(withTimeInterval: 1.5 + (Double(index)*0.1), repeats: false) { timer in
                self.cardBehaviour.removeItem(cardView)
                UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Constants.matchCardAnimationDuration,
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    cardView.center = self.numberOfSetsLabel.center
                    cardView.transform = CGAffineTransform.identity.scaledBy(x: Constants.matchCardAnimationScaleDown, y: Constants.matchCardAnimationScaleDown)
                    cardView.alpha = 0
            } )}
        }

        Timer.scheduledTimer(withTimeInterval: 2.7, repeats: false) { timer in
            self.game.touchCard(card: set.first!.card!)
            self.updateViewFromModel()
            self.cardGrid.isUserInteractionEnabled = true
            self.dealButton.isUserInteractionEnabled = true
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
    
    private func removeGestures() {
        if cardGrid != nil, swipe != nil, rotate != nil {
            cardGrid.removeGestureRecognizer(swipe!)
            cardGrid.removeGestureRecognizer(rotate!)
        }
    }
    
    private func addGestures() {
        if cardGrid != nil, swipe != nil, rotate != nil {
            if dealButton.isEnabled {
                cardGrid.addGestureRecognizer(swipe!)
            }
            cardGrid.addGestureRecognizer(rotate!)
        }
    }
}

struct Constants {
    static var cardRatio: CGFloat = 5.0/8.0
    static var drawCardAnimationDuration: TimeInterval = 0.8
    static var flipCardAnimationDuration: TimeInterval = 0.6
    static var matchCardAnimationDuration: TimeInterval = 1.0
    static var matchCardAnimationScaleDown: CGFloat = 0.3
    static var behaviorResistance: CGFloat = 0
    static var behaviorElasticity: CGFloat = 1.0
    static var behaviorPushMagnitudeMinimum: CGFloat = 1.0
    static var behaviorPushMagnitudeRandomFactor: CGFloat = 1.0
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
