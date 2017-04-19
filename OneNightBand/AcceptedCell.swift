//
//  AcceptedCell.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 4/18/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit

class AcceptedCell: UICollectionViewCell {
    @IBOutlet weak var bandImageView: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBAction func dismissPressed(_ sender: Any) {
    }

    @IBAction func viewBandPressed(_ sender: Any) {
    }
    @IBOutlet weak var bandNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
