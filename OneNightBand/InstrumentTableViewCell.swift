//
//  InstrumentTableViewCell.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 2/27/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit

class InstrumentTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.removeInstrument.isHidden = true
    }

    @IBOutlet weak var skillLabel: UILabel!
    @IBAction func removeInstrumentTouched(_ sender: Any) {
    }
    @IBOutlet weak var removeInstrument: UIButton!
    @IBOutlet weak var instrumentLabel: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
