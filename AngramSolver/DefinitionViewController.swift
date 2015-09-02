//
//  DefinitionViewController.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-08-27.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import UIKit

class DefinitionViewController: UIViewController {
    
    //var path = "http://services.aonaware.com/DictService/DictService.asmx/DefineInDict?dictId=wn&"
    var path = "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/"
    var word = "default"
    var key = "?key=5f4c9f15-4b63-4f5f-abd3-6fa205c279c3"
    
    var textManager:TextViewManager = TextViewManager()
    
    @IBOutlet weak var definitionTextView: UITextView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var functionalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordLabel.text = word
        definitionTextView.text = ""
        getDefinition(word)
    }
    
    //Retrieve word definition.
    func getDefinition(word: String) {
        path += (word) + (key)
        RESTManager.singleton.makeHTTPGetRequest(path, callBack: setDefinition)
    }
    
    //Set text displayed on definitionTextView.
    func setDefinition(xmlDoc   : AEXMLDocument) {
        let definition = xmlDoc.root
        let definitionObj = textManager.parseDefinition(definition)
        self.definitionTextView.setValue(definitionObj.definition, forKey: "contentToHTMLString")
        do {
            try self.definitionTextView.attributedText =  NSAttributedString(data: definitionObj.definition.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            
              try self.functionalLabel.attributedText =  NSAttributedString(data: definitionObj.functionalLabel.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        } catch {
            
        }
    }
}
