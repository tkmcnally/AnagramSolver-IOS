//
//  ResultCell.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-09-01.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
    
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}