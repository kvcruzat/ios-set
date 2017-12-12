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
    }

    @IBAction func newGame(_ sender: UIButton) {
    }
    
    @IBAction func dealCards(_ sender: UIButton) {
    }
    

}

