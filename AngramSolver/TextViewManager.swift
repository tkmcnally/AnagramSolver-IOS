//
//  TextViewManager.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-08-27.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import Foundation

class TextViewManager: NSObject {
    
    func parseDefinition(doc: AEXMLElement) -> Definition {
        
        var word = ""
        var functionalLabel = ""
        var definition = ""

        word = getWord(doc)
        functionalLabel = getFunctionalLabel(doc)
        definition = getDefinition(doc)
        
        return Definition(word: word, definition: definition, functionalLabel: functionalLabel)
    }
    
    
    func getWord(doc: AEXMLElement) -> String {
        return doc["entry"]["ew"].stringValue
    }
    
    func getFunctionalLabel(doc: AEXMLElement) -> String {
        return doc["entry"]["fl"].stringValue
    }
    
    func getDefinition(doc: AEXMLElement) -> String {
        let defTag = doc["entry"]["def"]["dt"]
        var text:String = defTag.stringValue
        if defTag["sx"].parent != nil {
            text += defTag["sx"].stringValue
        }
        if defTag["sxn"].parent != nil {
            text += "<br>" + defTag["sxn"].stringValue
        }
        if defTag["un"].parent != nil {
            text += "<br>" + defTag["un"].stringValue
        }
        if defTag["ca"].parent != nil {
            text += "<br>" + defTag["ca"].stringValue
        }
        if defTag["cat"].parent != nil {
            text += "<i>" + defTag["cat"].stringValue + "</i>"
        }
        if defTag["vi"].parent != nil {
            text += "<br>" + defTag["vi"].stringValue
        }
        if defTag["aq"].parent != nil {
            text += "<br>" + defTag["aq"].stringValue
        }
        if defTag["dx"].parent != nil {
            text += "<br>" + defTag["dx"].stringValue
        }
        if defTag["dxt"].parent != nil {
            text += "<br>" + defTag["dxt"].stringValue
        }
        if defTag["dxn"].parent != nil {
            text += "<br>" + defTag["dxn"].stringValue
        }
        if defTag["sd"].parent != nil {
            text += "<br>" + defTag["sd"].stringValue
        }

        return text
    }
    
    
    
}