//
//  Card.swift
//  Set
//
//  Created by Khen Cruzat on 11/12/2017.
//  Copyright © 2017 Khen Cruzat. All rights reserved.
//

import Foundation

struct Card: Equatable {
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    let identifier: [String:Int]
    
    init(identifier: [String:Int]){
        self.identifier = identifier
    }
}
