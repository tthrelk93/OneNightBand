//
//  SessionViewerCollectionCellCollectionViewCell.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/17/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import UIKit

class SessionViewerCollectionCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sessionCellButton: UIButton?
    
    @IBOutlet weak var sessionCellLabel: UILabel?
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
        self.sessionCellLabel?.textColor = UIColor.white
        //self.layer.cornerRadius = 4
    }
    @IBAction func sessionCellButtonTouched(_ sender: AnyObject) {
    
}
}
