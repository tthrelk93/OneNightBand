//
//  SessionViewerCollectionCellCollectionViewCell.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/17/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import UIKit


/*protocol LoadProperSessionProtocol {
    func loadThisSession(indexPath: IndexPath)
}*/

class SessionCell: UICollectionViewCell {
    //var delegate: LoadProperSessionProtocol!
   
    
    @IBOutlet weak var sessionCellLabel: UILabel!
    @IBOutlet weak var sessionCellImageView: UIImageView!
    var sessionId: String?
    
    override func awakeFromNib() {
        //self.backgroundColor = UIColor.clear
        //self.sessionCellLabel?.textColor = UIColor.white
        //self.layer.cornerRadius = 4
    }
   
    @IBAction func cellTouched(_ sender: AnyObject) {
        
        
    }
}
