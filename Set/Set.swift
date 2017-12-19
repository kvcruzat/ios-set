//
//  Set.swift
//  Set
//
//  Created by Khen Cruzat on 11/12/2017.
//  Copyright © 2017 Khen Cruzat. All rights reserved.
//

import Foundation

struct Set {
    
    var deckCards = [SetCard]()
    var faceUpCards = [SetCard]()
    var matchedCards = [SetCard]()
    var selectedCards = [SetCard]()
    
    var score = 0
    
    private var multiplier = 100
    
    mutating func drawOneCard() {
        if deckCards.count > 0 {
            let card = deckCards.removeFirst()
            faceUpCards.append(card)
        }
    }
    
    mutating func drawThreeCards() {
        for _ in 1...3 {
            drawOneCard()
        }
    }
    
    mutating func replaceCards(set: [SetCard]){
        if deckCards.count > 0 {
            for card in set {
                faceUpCards[faceUpCards.index(of: card)!] = deckCards.removeFirst()
            }
        } else {
            for card in set {
                faceUpCards.remove(at: faceUpCards.index(of: card)!)
            }
        }
    }
    
    mutating func touchCard(card: SetCard){
        if selectedCards.count == 3 {
            if matchedCards.contains(array: selectedCards) {
                replaceCards(set: selectedCards)
                selectedCards.removeAll()
                if !matchedCards.contains(card){ selectedCards.append(card) }
            } else {
                selectedCards.removeAll()
            }
        } else if selectedCards.contains(card) {
            score -= 1
            selectedCards.remove(at: selectedCards.index(of: card)!)
        } else if selectedCards.count < 3 { selectedCards.append(card)}
    }
    
    mutating func shuffleCards() {
        var last = faceUpCards.count - 1
        
        while last > 0 {
            let rand = last.arc4random
            faceUpCards.swapAt(rand, last)
            last -= 1
        }
        
    }
    
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
                score -= 5
                return false
                
            }
        }
        if faceUpCards.count > 39 {
            score += 1
            multiplier = 1
        } else {
            let newMultiplier = -((faceUpCards.count - 9) / 3) + 11
            if newMultiplier < multiplier {
                multiplier = newMultiplier
            }
            score += multiplier
        }
        
//        for index in selectedCards.indices {
//            let card = selectedCards[index]
//            faceUpCards.remove(at: faceUpCards.index(of: card)!)
//        }
        
        matchedCards += selectedCards
        
        return true
        
    }
    
    init(){
        for colour in 0...2 {
            for shape in 0...2 {
                for shading in 0...2 {
                    for amount in 1...3 {
                        let id = ["colour": colour, "shape":shape, "shading":shading, "amount":amount]
                        let card = SetCard(identifier: id)
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
        
        for _ in 1...12 {
            drawOneCard()
        }
    }
}

extension Array where Element: Equatable {
    var isUnique: Bool {
        for index in 0..<Int(count)-1 {
            for index2 in index+1..<Int(count) {
                if self[index] == self[index2] { return false}
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

extension Array where Element: Equatable {
    func contains(array: [Element]) -> Bool {
        for item in array {
            if !self.contains(item) { return false }
        }
        return true
    }
}
