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
    
    mutating func checkMatch() -> Bool{
        
        var colourAttributes = [Int]()
        var shapeAttributes = [Int]()
        var shadingAttributes = [Int]()
        var amountAttributes = [Int]()
        
        for index in selectedCards.indices{
            colourAttributes.append(selectedCards[index].identifier["colour"]!)
            shapeAttributes.append(selectedCards[index].identifier["shape"]!)
            shadingAttributes.append(selectedCards[index].identifier["shading"]!)
            amountAttributes.append(selectedCards[index].identifier["amount"]!)
        }
        
        let attributes = [colourAttributes, shapeAttributes, shadingAttributes, amountAttributes]
        
        for attribute in attributes {
            if !(attribute.isUnique || attribute.isSame) {
                print(attributes)
                return false
            }
        }
        
        for index in selectedCards.indices {
            let card = selectedCards[index]
            faceUpCards.remove(at: faceUpCards.index(of: card)!)
        }
        
        matchedCards += selectedCards
        
        return true
        
    }
    
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
        
        var last = deckCards.count - 1
        
        while last > 0 {
            let rand = Int(arc4random_uniform(UInt32(last)))
            deckCards.swapAt(last, rand)
            last -= 1
        }
    }
}

extension Array where Element: Equatable {
    var isUnique: Bool {
        for index in 1...Int(count)-1 {
            if self[index] == self[index - 1] {
                print("\(self[index]) == \(self[index-1])")
                return false
            }
        }
        return true
    }
}

extension Array where Element: Equatable {
    var isSame: Bool {
        for index in 1...Int(count)-1 {
            if self[index] != self[index - 1] {
                print("\(self[index]) != \(self[index-1])")
                return false
            }
        }
        return true
    }
}
