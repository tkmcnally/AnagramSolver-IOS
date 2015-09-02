//
//  Definition.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-09-01.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import Foundation

class Definition {
    
    var word:String
    
    var definition:String
    
    var functionalLabel:String
    
    init(word: String, definition: String, functionalLabel: String) {
        self.word = word
        self.definition = definition
        self.functionalLabel = functionalLabel
    }
    
}