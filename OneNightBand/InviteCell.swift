//
//  InviteCell.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 2/5/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit

class InviteCell: UICollectionViewCell {

    @IBAction func acceptButtonPressed(_ sender: Any) {
    }
    @IBAction func declineButtonPressed(_ sender: Any) {
    }
    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var senderPic: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var instrumentNeeded: UILabel!
    @IBOutlet weak var sessionDate: UILabel!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
