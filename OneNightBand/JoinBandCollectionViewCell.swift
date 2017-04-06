//
//  JoinBandCollectionViewCell.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 4/6/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit

class JoinBandCollectionViewCell: UICollectionViewCell {
    @IBAction func viewBandPagePressed(_ sender: Any) {
    }
    @IBAction func joinBandPressed(_ sender: Any) {
    }
    @IBOutlet weak var bandImageView: UIImageView!

    @IBOutlet weak var bandName: UILabel!
    @IBOutlet weak var instrumentWanted: UILabel!
    @IBOutlet weak var experienceWanted: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var moreInfoTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        bandImageView.layer.cornerRadius = bandImageView.frame.width/2
        // Initialization code
    }

}
