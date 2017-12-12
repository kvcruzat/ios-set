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
    let colours = [UIColor.red, UIColor.orange, UIColor.black]
    let shadings = ["filled", "outline", "striped"]
    
    @IBOutlet var cardButtons: [UIButton]!{
        didSet {
            for index in cardButtons.indices {
                let card = game.deckCards.removeFirst()
                game.faceUpCards.append(card)
                
                let button = cardButtons[index]
                let identifier = game.faceUpCards[index].identifier
                let buttonTitle = String(repeating: shapes[identifier["shape"]!], count: identifier["amount"]!)
                button.setTitle(buttonTitle, for: UIControlState.normal)
            }
        }
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.index(of: sender){
            let card = game.faceUpCards[cardNumber]
            if game.selectedCards.contains(card){
                deselectCard(index: cardNumber)
                game.selectedCards.remove(at: game.selectedCards.index(of: card)!)
            } else if game.selectedCards.count < 3, !game.selectedCards.contains(card){
                selectCard(index: cardNumber)
                game.selectedCards.append(card)
            }
        }
    }

    @IBAction func newGame(_ sender: UIButton) {
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
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
    

}

