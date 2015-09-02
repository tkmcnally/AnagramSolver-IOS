//
//  ResultPOJO.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-09-02.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import Foundation

class ResultPOJO {
    
    var word: String
    var score: Int
    
    init(word: String, score: Int) {
        self.word = word
        self.score = score
    }
    
    init() {
        self.word = ""
        self.score = 0
    }
    
}