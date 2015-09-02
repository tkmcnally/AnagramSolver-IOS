//
//  TableViewController.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-08-27.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    //MARK: Properties
    @IBOutlet weak var searchBar: UISearchBar!
    var messageLabel:UILabel = UILabel()
    
    var filteredResults: [Int: [ResultPOJO]]!
    var selectedWord: String!
    
    var utils:Utils = Utils()
    var path:NSString = ""
    var cPath:UnsafePointer<Int8> = nil
    
    var sortMode:String = ""
    var lengthKeys:[Int] = [Int]()
    var scoreKeys:[Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use delegate methods defined in this class
        self.searchBar.delegate = self
        
        //Initialize dictionary
        filteredResults = [Int: [ResultPOJO]]()
        
        path = utils.getResourcePath("Traditional_Dawg_For_Word-List", fileType: "dat")
        utils = Utils()
        cPath = path.UTF8String

        initializeDawg(cPath)
        
        navigationItem.title = "Anagram Solver"
        
        self.searchBar.placeholder = "Enter your scrambled word"
        
        messageLabel = UILabel.init(frame: CGRect(x: self.view.center.x-15, y: self.view.frame.size.height/2, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        messageLabel.text = "No results found!"
        messageLabel.sizeToFit()
        messageLabel.tag = 404

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UITableView: Number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if filteredResults.count == 0 && searchBar.text!.isEmpty {
            self.tableView.hidden = true
        } else if filteredResults.count == 0 {
            self.view.addSubview(messageLabel)
            self.tableView.hidden = true
        } else {
            for v in self.view.subviews {
                if v.tag == messageLabel.tag {
                    v.removeFromSuperview()
                }
            }
            self.tableView.hidden = false
        }
        return filteredResults.count;
    }
    
    //UITableView: Number of rows in section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortMode == "Score" {
            return filteredResults[scoreKeys[section]]!.count;
        } else {
            return filteredResults[lengthKeys[section]]!.count;
        }
    }
    
     //UITableView: UITableViewCell for a [section][row]
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ResultCell = self.tableView.dequeueReusableCellWithIdentifier("LabelCell", forIndexPath: indexPath) as! ResultCell
        var section:[ResultPOJO] = [ResultPOJO]()
        if sortMode == "Score" {
            section = filteredResults[scoreKeys[indexPath.section]]!
        } else {
            section = filteredResults[lengthKeys[indexPath.section]]!
        }
        
        let resultObj = section[indexPath.row]
        
        cell.wordLabel.text = resultObj.word
        cell.scoreLabel.text = String(resultObj.score)
        return cell
    }
    
    //UITableView: Label for section header
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if filteredResults[section]?.count == 0 {
            return nil
        }
        
        if sortMode == "Score" {
            var suffix:String = "Points"
            if(scoreKeys[section] == 1) {
                suffix = "Point"
            }
            return String(scoreKeys[section]) + " " + suffix
        } else {
            var suffix:String = "Letters"
            if(lengthKeys[section] == 1) {
                suffix = "Letter"
            }
            return String(lengthKeys[section]) + " " + suffix
        }
    }
    
    //UISearchBar: Set the maximum character length for a search
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let charValue = text.unicodeScalars.first?.value;
        if (charValue >= 65 && charValue <= 90) || (charValue >= 97 && charValue <= 122) || charValue == nil {
            return ((searchBar.text?.characters.count)! + text.characters.count - range.length <= 15)
        } else {
            return false
        }
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scopes = self.searchBar.scopeButtonTitles as [String]!
        let selectedScope = scopes[self.searchBar.selectedScopeButtonIndex] as String
        sortMode = selectedScope
        if(searchBar.text!.characters.count >= 1) {
            doSearch(searchBar.text!, scope: selectedScope)
        } else {
            clearResults()
            navigationItem.title = "Anagram Solver"
        }

        tableView.reloadData()
    }
    
    //Search Bar onChange()
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        let scopes = self.searchBar.scopeButtonTitles as [String]!
        let selectedScope = scopes[self.searchBar.selectedScopeButtonIndex] as String
        sortMode = selectedScope
        if(searchText.characters.count >= 1) {
            doSearch(searchText, scope: selectedScope)
        } else {
            navigationItem.title = "Anagram Solver"
            clearResults()
        }
        tableView.reloadData()
    }
    
    func doSearch(searchText: String, scope: String) {
        let resultSet:UnsafeMutablePointer<UnsafeMutablePointer<CChar>>  = mainHelper(NSString(UTF8String: searchText)!.UTF8String)
        var i = 0
        var not_end = true;
        
        clearResults()
        while not_end {
            let w = resultSet[i]
            let p = String.fromCString(w)
            if p != "_EOR" && p != nil {
                addResult(p!, scope: scope)
                i++
            } else {
                not_end = false;
            }
        }
        resultSet.destroy()
        lengthKeys.sortInPlace()
        scoreKeys.sortInPlace()
        
        //Change title of this view to persist title change in the Back button.
        navigationItem.title = "Results"
    }
    
    //Add a word to the filteredResults dictionary
    func addResult(word: String, scope: String) {
        var filterIndex:Int = 0
        let s = utils.getWordValue(word)

        if scope == "Score" {
            if !scoreKeys.contains(s) {
                scoreKeys.append(s)
            }
            filterIndex = s
        } else {
            let n = word.characters.count
            if !lengthKeys.contains(n) {
                lengthKeys.append(n)
            }
            filterIndex = n
        }
        
        if let _ = filteredResults[filterIndex] {
            filteredResults[filterIndex]?.append(ResultPOJO(word: word, score: s))
        } else {
            filteredResults[filterIndex] = [ResultPOJO]()
            filteredResults[filterIndex]?.append(ResultPOJO(word: word, score: s))
        }
        filteredResults[filterIndex]?.sortInPlace({$0.word < $1.word})
    }
    
    //Clear the results list
    func clearResults() {
            filteredResults.removeAll()
            lengthKeys.removeAll()
            scoreKeys.removeAll()
        
            //Initialize dictionary
            filteredResults = [Int: [ResultPOJO]]()
    }
    
    
    //Set selected word in the DefinitionViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as? DefinitionWebViewController
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPathForCell(cell) {
            var index:Int
            if sortMode == "Score" {
                index = scoreKeys[indexPath.section]
            } else {
                index = lengthKeys[indexPath.section]
            }
            let section = filteredResults[index]!
            destination?.word = section[indexPath.row].word
        }
    }
    
    
}
