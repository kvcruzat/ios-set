//
//  Set.swift
//  Set
//
//  Created by Khen Cruzat on 11/12/2017.
//  Copyright © 2017 Khen Cruzat. All rights reserved.
//

import Foundation

struct Set {
    
    var deckCards = [Card]()
    var faceUpCards = [Card]()
    var matchedCards = [Card]()
    var selectedCards = [Card]()
    
    init(){
        for colour in 0...2 {
            for shape in 0...2 {
                for shading in 0...2 {
                    for amount in 1...3 {
                        let id = ["colour": colour, "shape":shape, "shading":shading, "amount":amount]
                        let card = Card(identifier: id)
                        deckCards.append(card)
                    }
                }
            }
        }
    }
}
