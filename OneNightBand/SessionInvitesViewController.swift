//
//  SessionInvitesViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/25/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class SessionInvitesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    //var inviteCollectionView: UICollectionView
    var inviteArray = [Invite]()
    var snapKey = [String: Any]()
    
    @IBOutlet weak var inviteCollectionView: UICollectionView!
    
   let emptyLabel: UILabel = {
        var tempLabel = UILabel()
        tempLabel.text = "You have 0 pending invites"
        tempLabel.textColor = UIColor.black
        tempLabel.font = UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightLight)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    
    }()
    func setupEmptyLabel(){
        emptyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    
    
    var sizingCell: InviteCell?
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.view.addSubview(emptyLabel)
        setupEmptyLabel()
        emptyLabel.isHidden = true
        
        
        let currentUser = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("users").child(currentUser!).child("invites").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount != 0{
                self.emptyLabel.isHidden = true
                self.inviteCollectionView.isHidden = false
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                //var index = 0
                
                for snap in snapshots{
                    
                    if let dictionary = snap.value as? [String: Any] {
                        
                        //self.snapKey = dictionary
                        let invite = Invite()
                        invite.setValuesForKeys(dictionary)
                        self.inviteArray.append(invite)
                        //print(dictionary)
                        let cellNib = UINib(nibName: "InviteCell", bundle: nil)
                        self.inviteCollectionView.register(cellNib, forCellWithReuseIdentifier: "InviteCell")
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! InviteCell?)!
                        //self.inviteCollectionView.backgroundColor = UIColor.clear
                        self.inviteCollectionView.dataSource = self
                        self.inviteCollectionView.delegate = self

                    
                    }
                    }
                }
            

        
           
            }else{
                self.inviteCollectionView.isHidden = true
                self.emptyLabel.isHidden = false
            }

        })
    
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return inviteArray.count
        
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteCell", for: indexPath as IndexPath) as! InviteCell
        
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        
        
        return cell

        
    }
    func configureCell(_ cell: InviteCell, forIndexPath indexPath: NSIndexPath){
        
        //cell.layer.borderColor = UIColor.white.cgColor
        //cell.layer.borderWidth = 2
        self.ref.child("users").child(inviteArray[indexPath.row].sender!).observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
            for snap in snapshots{
                if snap.key == "name"{
                    cell.senderName.text = snap.value as? String
                }
                if snap.key == "profileImageUrl"{
                    cell.senderPic.loadImageUsingCacheWithUrlString((snap.value as! [String]).first!)
                }
            }
        cell.instrumentNeeded.text = self.inviteArray[indexPath.row].instrumentNeeded

        cell.sessionDate.text = self.inviteArray[indexPath.row].sessionDate
        cell.sessionName.text = self.inviteArray[indexPath.row].sessionID
            self.ref.child("sessions").child(self.inviteArray[indexPath.row].sessionID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                for snap in snapshots{
                    if snap.key == "sessionName"{
                        cell.sessionName.text = snap.value as! String?
                    }
                    if snap.key == "sessionBio"{
                        cell.sessionDescription.text = snap.value as? String
                    }
                    if snap.key == "sessionDate"{
                        cell.sessionDate.text = snap.value as? String
                    }
                    if snap.key == "sessionPictureURL"{
                        cell.sessionImage.loadImageUsingCacheWithUrlString(snap.value as! String)
                    }
                }

                
                
            })
        })
        }

    
    
    
    //PageController Functions
    
    
}
