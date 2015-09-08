//
//  Utils.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-08-28.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import Foundation

class Utils: NSObject {
    
    var letterValues:Dictionary<Character, Int> = ["A":1, "B":3, "C":3, "D":2,"E":1,"F":4,"G":2,"H":4,"I":1,"J":8,"K":5,"L":1,"M":3,"N":1,"O":1,"P":3,"Q":10,"R":1,"S":1,"T":1,"U":1,"V":4,"W":4,"X":8,"Y":4,"Z":10]
    
    func getResourcePath(fileName: String, fileType: String) -> String {
        return NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)!
    }
    
    func getWordValue(word: String) -> Int {
        var score = 0
        for l in Array(word) {
            score += letterValues[l]!
        }
        return score
    }
    
    func charValue(char: Character) -> Int {
        return Int(Array(String(char).unicodeScalars)[0].value)
//        return Int((String(char).unicodeScalars.first?.value)!)
    }
    
}
