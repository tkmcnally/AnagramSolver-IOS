//
//  GeneralLabelCell.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-09-02.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import Foundation
import UIKit

class GeneralLabelCell: UITableViewCell {
    
    @IBOutlet weak var labelCell: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}