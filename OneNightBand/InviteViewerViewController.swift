//
//  InviteViewerViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 4/18/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct AuditAccepted {
    var bandName = String()
    var bandID = String()
    var picURL = String()
    
}

class AuditReceived: NSObject {
    var bandName = String()
    var userID = String()
    var bandID = String()
    var instrumentAuditFor = String()
    var bandPicURL = String()
    var additInfo1 = String()
    var additInfo2 = String()
    var bandType = String()
    var wantedID = String()
    var responseID = String()
}


class InviteViewerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, AcceptDeclineDelegate {
    
    
    @IBOutlet weak var wantedCollect: UICollectionView!
    @IBOutlet weak var auditionsAcceptedCollect: UICollectionView!
    
    @IBOutlet weak var invitesCollect: UICollectionView!
    
    var sender: String?
    var ref = FIRDatabase.database().reference()
    var currentUser = FIRAuth.auth()?.currentUser?.uid
    var inviteArray = [Invite]()
    var auditReceivedArray = [AuditReceived]()
    var auditAcceptedArray = [AuditAccepted]()
    var cellArray = [InviteCell]()
    var sizingCell1 = InviteCell()
    var sizingCell2 = WantedReceivedCell()
    

    var wantedAdsOnFeed = [String]()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            ref.child("users").child(currentUser!).observeSingleEvent(of: .value, with: {(snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            if snap.key == "invites"{
                                for inviteSnap in (snap.children.allObjects as! [FIRDataSnapshot]){
                                    if let invites = inviteSnap.value as? [String:Any]{
                                        let invite = Invite()
                                        invite.setValuesForKeys(invites)
                                        self.inviteArray.append(invite)
                                    }
                                }
                            }
                            if snap.key == "wantedAds"{
                                for wantedSnap in (snap.children.allObjects as? [FIRDataSnapshot])!{
                                    self.wantedAdsOnFeed.append(wantedSnap.value as! String)
                                }
                            }
                        }
                }
                
                if self.sender == "invite"{
                    DispatchQueue.main.async {
                        for _ in self.inviteArray{
                            let cellNib = UINib(nibName: "InviteCell", bundle: nil)
                            self.invitesCollect.register(cellNib, forCellWithReuseIdentifier: "InviteCell")
                            self.sizingCell1 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! InviteCell?)!
                            //self.inviteCollectionView.backgroundColor = UIColor.clear
                            self.invitesCollect.dataSource = self
                            self.invitesCollect.delegate = self
                            self.invitesCollect.gestureRecognizers?.first?.cancelsTouchesInView = false
                            self.invitesCollect.gestureRecognizers?.first?.delaysTouchesBegan = false
                            
                        }
                    }

                } else if self.sender == "auditReceived"{
                    self.ref.child("wantedAds").observeSingleEvent(of: .value, with: {(snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            var auditReceivedDict = [String:Any]()
                            for snap in snapshots{
                                if self.wantedAdsOnFeed.contains(snap.key){
                                    
                                    if let ad = snap.value as? [String:Any]{
                                        
                                        auditReceivedDict["bandName"] = ad["bandName"]
                                        auditReceivedDict["bandID"] = ad["bandID"]
                                        auditReceivedDict["instrumentAuditFor"] = (ad["instrumentNeeded"] as! [String]).first
                                        auditReceivedDict["bandPicURL"] = ad["wantedImage"]
                                        auditReceivedDict["wantedID"] = ad["wantedID"]
                                        auditReceivedDict["bandType"] = ad["bandType"]
                                        let adResponses = ad["responses"] as? [String:Any]
                                        for (key, value) in adResponses!{
                                            auditReceivedDict["responseID"] = key
                                            auditReceivedDict["userID"] = (value as! [String:Any])["respondingArtist"] as! String
                                            auditReceivedDict["additInfo1"] = (value as! [String:Any])["infoText1"]
                                            auditReceivedDict["additInfo2"] = (value as! [String:Any])["infoText2"]
                                            
                                        }
                                        
                                        
                                        
                                    
                                    var tempAuditReceived = AuditReceived()
                                    tempAuditReceived.setValuesForKeys(auditReceivedDict)
                                    self.auditReceivedArray.append(tempAuditReceived)
                                    }
                                    
                                }
                            }
                        }
                        DispatchQueue.main.async{
                            for _ in self.auditReceivedArray{
                                let cellNib = UINib(nibName: "WantedReceivedCell", bundle: nil)
                                self.wantedCollect.register(cellNib, forCellWithReuseIdentifier: "WantedReceivedCell")
                                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! WantedReceivedCell)
                                //self.inviteCollectionView.backgroundColor = UIColor.clear
                                self.wantedCollect.dataSource = self
                                self.wantedCollect.delegate = self
                                self.wantedCollect.gestureRecognizers?.first?.cancelsTouchesInView = false
                                self.wantedCollect.gestureRecognizers?.first?.delaysTouchesBegan = false
                            }
                        }
                    })
                    
                } else {
                    
                }
                
        
        
        
                
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var onbArray = [String]()
    var bandArray = [String]()
    func acceptPressed(indexPathRow: Int, indexPath: IndexPath, curCell: InviteCell){
        DispatchQueue.main.async {
            
            var tempDict = [String: Any]()
            var tempDict2 = [String: Any]()
            var tempDict3 = [String: Any]()
            print("accept Pressed")
            
            for invite in 0...self.inviteArray.count - 1{
                if curCell == self.cellArray[invite]{
                    if self.inviteArray[indexPathRow].bandType == "onb"{
                        FIRDatabase.database().reference().child("users").child(self.currentUser!).child("artistsONBs").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            for snap in snapshots{
                                self.onbArray.append(snap.value as! String)
                            }
                            self.onbArray.append(self.inviteArray[invite].bandID!)
                            tempDict2["artistsONBs"] = self.onbArray
                            FIRDatabase.database().reference().child("users").child(self.currentUser!).updateChildValues(tempDict2)
                        }
                        FIRDatabase.database().reference().child("oneNightBands").child(curCell.bandID).child("onbArtists").observeSingleEvent(of: .value, with: { (snapshot) in
                            var dictionary = [String:Any]()
                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                for snap in snapshots{
                                    dictionary[snap.key] = snap.value
                                }
                                dictionary[self.currentUser!] = self.inviteArray[invite].instrumentNeeded
                                tempDict3["onbArtists"] = dictionary
                                
                                FIRDatabase.database().reference().child("oneNightBands").child(curCell.bandID).updateChildValues(tempDict3)
                            }
                            FIRDatabase.database().reference().child("users").child(self.currentUser!).child("invites").observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                var tempDict6 = [String:Any]()
                                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                    //var index = 0
                                    
                                    var temp = self.inviteArray[invite].dictionaryWithValues(forKeys: ["inviteKey"])
                                    for snap in snapshots{
                                        
                                        if (snap.value as! [String: Any])["inviteKey"] as! String == temp["inviteKey"] as! String{
                                            
                                            
                                        }else{
                                            tempDict[snap.key] = snap.value
                                        }
                                    }
                                    tempDict6["invites"] = tempDict
                                    FIRDatabase.database().reference().child("users").child(self.currentUser!).updateChildValues(tempDict6)
                                }
                                DispatchQueue.main.async {
                                    
                                    self.inviteArray.remove(at: invite)
                                    self.cellArray.remove(at: invite)
                                    self.invitesCollect.deleteItems(at: [IndexPath(row: invite, section: 0)])
                                    print("InviteCollectionViewCells: \(self.invitesCollect.visibleCells.count)")
                                }
                                
                            })
                            })
                        })
                } else {
                        FIRDatabase.database().reference().child("users").child(self.currentUser!).child("artistsBands").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                //var index = 0
                                for snap in snapshots{
                                    self.onbArray.append(snap.value as! String)
                                }
                                self.onbArray.append(self.inviteArray[invite].bandID!)
                                tempDict2["artistsbands"] = self.bandArray
                                FIRDatabase.database().reference().child("users").child(self.currentUser!).updateChildValues(tempDict2)
                            }
                            FIRDatabase.database().reference().child("bands").child(curCell.bandID).child("bandMembers").observeSingleEvent(of: .value, with: { (snapshot) in
                                
                                var dictionary = [String:Any]()
                                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                    for snap in snapshots{
                                        dictionary[snap.key] = snap.value
                                    }
                                    dictionary[self.currentUser!] = self.inviteArray[invite].instrumentNeeded
                                    tempDict3["bandMembers"] = dictionary
                                    FIRDatabase.database().reference().child("bands").child(curCell.bandID).updateChildValues(tempDict3)
                                }
                                FIRDatabase.database().reference().child("users").child(self.currentUser!).child("invites").observeSingleEvent(of: .value, with: { (snapshot) in
                                    var tempDict6 = [String:Any]()
                                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                        var temp = self.inviteArray[invite].dictionaryWithValues(forKeys: ["inviteKey"])
                                        for snap in snapshots{
                                            
                                            if (snap.value as! [String: Any])["inviteKey"] as! String == temp["inviteKey"] as! String{
                                            }else{
                                                tempDict[snap.key] = snap.value
                                            }
                                        }
                                        tempDict6["invites"] = tempDict
                                        FIRDatabase.database().reference().child("users").child(self.currentUser!).updateChildValues(tempDict6)
                                    }
                                    DispatchQueue.main.async {
                                        self.inviteArray.remove(at: invite)
                                        self.cellArray.remove(at: invite)
                                        self.invitesCollect.deleteItems(at: [IndexPath(row: invite, section: 0)])
                                        print("InviteCollectionViewCells: \(self.invitesCollect.visibleCells.count)")
                                    }
                                })
                            })
                        })
                    }
                    break
                
                }
            }
        }
    }
    
    func declinePressed(indexPathRow: Int, indexPath: IndexPath, curCell: InviteCell){
        for invite in 0...self.cellArray.count-1{
            
            if curCell == self.cellArray[invite]{
                FIRDatabase.database().reference().child("users").child(self.currentUser!).child("invites").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    var tempDict6 = [String:Any]()
                    var tempDict = [String:Any]()
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        //var index = 0
                        print(indexPath.row)
                        var temp = self.inviteArray[invite].dictionaryWithValues(forKeys: ["inviteKey"])
                        for snap in snapshots{
                            
                            if (snap.value as! [String: Any])["inviteKey"] as! String == temp["inviteKey"] as! String{
                                
                            }else{
                                tempDict[snap.key] = snap.value
                            }
                        }
                        tempDict6["invites"] = tempDict
                        FIRDatabase.database().reference().child("users").child(self.currentUser!).updateChildValues(tempDict6)
                        
                        
                        
                        
                    }
                    DispatchQueue.main.async {
                        
                        self.inviteArray.remove(at: invite)
                        self.cellArray.remove(at: invite)
                        self.invitesCollect.deleteItems(at: [IndexPath(row: invite, section: 0)])
                        print("InviteCollectionViewCells: \(self.invitesCollect.visibleCells.count)")
                    }
                    
                })
                
                
                break
                
            }
            
        }
        
    }
    func acceptPressedWanted(indexPathRow: Int, indexPath: IndexPath, curCell: WantedReceivedCell){
        //add senderID to band/ONB artists. 
        //add band/onb to senders bands/onbs.
        //remove wantedAd From collect
        //add band name and bandID to acceptedAuditions of sender
        for wanted in 0...self.auditReceivedArray.count - 1{
            if curCell == self.cellArray2[wanted]{
        if curCell.bandType == "onb"{
            ref.child("oneNightBands").child(curCell.bandID).child("onbArtists").observeSingleEvent(of: .value, with: {(snapshot) in
                var values1 = [String:Any]()
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        values1[snap.key] = snap.value as! String
                    }
                }
                values1[curCell.artistID] = curCell.instrumentLabel.text
                self.ref.child("oneNightBands").child(curCell.bandID).child("onbArtists").updateChildValues(values1)
                self.ref.child("wantedAds").child(curCell.wantedID).child("responses").observeSingleEvent(of: .value, with: {(snapshot) in
                    var tempDict = [String:Any]()
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            tempDict[snap.key] = snap.value as! [String:Any]
                        }
                        print("responseID: \(curCell.responseID)")
                        for (key,_) in tempDict{
                            if key == curCell.responseID{
                                print(curCell.responseID)
                                tempDict.removeValue(forKey: key)
                                break
                            }
                        }
                        self.ref.child("wantedAds").child(curCell.wantedID).child("responses").updateChildValues(tempDict)
                    }
                    
                })

                self.ref.child("users").child(curCell.artistID).observeSingleEvent(of: .value, with: {(snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        var auditDict = [String:Any]()
                        for snap in snapshots{
                            if snap.key == "acceptedAudits"{
                                for (key, value) in (snap.value as! [String:Any]){
                                    auditDict[key] = value
                                }
                                break
                            }
                        }
                        auditDict[curCell.bandNameLabel.text!] = curCell.bandID
                        self.ref.child("users").child(curCell.artistID).child("acceptedAudits").updateChildValues(auditDict)
                    }
                    DispatchQueue.main.async {
                        self.auditReceivedArray.remove(at: wanted)
                        self.cellArray2.remove(at: wanted)
                        self.wantedCollect.deleteItems(at: [IndexPath(row: wanted, section: 0)])
                    }

                    
                })
            })
        } else {
            ref.child("bands").child(curCell.bandID).child("bandMembers").observeSingleEvent(of: .value, with: {(snapshot) in
                var values1 = [String:Any]()
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        values1[snap.key] = snap.value as! String
                    }
                }
                values1[curCell.artistID] = curCell.instrumentLabel.text
                self.ref.child("bands").child("bandMembers").updateChildValues(values1)
                self.ref.child("wantedAds").child(curCell.wantedID).child("responses").observeSingleEvent(of: .value, with: {(snapshot) in
                    var tempDict = [String:Any]()
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            tempDict[snap.key] = snap.value as! [String:Any]
                        }
                        
                        for (key,_) in tempDict{
                            if key == curCell.responseID{
                                tempDict.removeValue(forKey: key)
                            }
                        }
                        self.ref.child("wantedAds").child(curCell.wantedID).child("responses").updateChildValues(tempDict)
                    }
                    
                })
                self.ref.child("users").child(curCell.artistID).observeSingleEvent(of: .value, with: {(snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        var auditDict = [String:Any]()
                        for snap in snapshots{
                            if snap.key == "acceptedAudits"{
                                for (key, value) in (snap.value as! [String:Any]){
                                    auditDict[key] = value
                                }
                                break
                            }
                        }
                        auditDict[curCell.bandNameLabel.text!] = curCell.bandID
                        self.ref.child("users").child(curCell.artistID).child("acceptedAudits").updateChildValues(auditDict)
                    }
                    DispatchQueue.main.async {
                        self.auditReceivedArray.remove(at: wanted)
                        self.cellArray2.remove(at: wanted)
                        self.wantedCollect.deleteItems(at: [IndexPath(row: wanted, section: 0)])
                    }

                    
                })
            })
            

                }
                break
            }
        }
        
        
    }
    func declinePressedWanted(indexPathRow: Int, indexPath: IndexPath, curCell: WantedReceivedCell){
        for wanted in 0...self.cellArray2.count-1{
            
            if curCell == self.cellArray2[wanted]{
                
                    DispatchQueue.main.async {
                        self.ref.child("wantedAds").child(curCell.wantedID).child("responses").child(curCell.responseID).removeValue()
                        self.auditReceivedArray.remove(at: wanted)
                        self.cellArray.remove(at: wanted)
                        self.wantedCollect.deleteItems(at: [IndexPath(row: wanted, section: 0)])
                        print("WantedCollectionViewCells: \(self.wantedCollect.visibleCells.count)")
                       
                    }
                break
            }
            
        }

    }
    


    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.sender == "invite"{
            return inviteArray.count
        }
        else if self.sender == "auditReceived"{
            return auditReceivedArray.count
        } else {
            return auditAcceptedArray.count
        }
        
    }
    
    var cellArray2 = [WantedReceivedCell]()
    var cellArray3 = [AcceptedCell]()
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        if collectionView == invitesCollect{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteCell", for: indexPath as IndexPath) as! InviteCell
            cell.acceptDeclineDelegate = self
        
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        
            cellArray.append(cell)
        
            return cell
        } else if collectionView == wantedCollect{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WantedReceivedCell", for: indexPath as IndexPath) as! WantedReceivedCell
            cell.acceptDeclineDelegate = self
            
            self.configureWantedCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            cellArray2.append(cell)
            
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AcceptedCell", for: indexPath as IndexPath) as! AcceptedCell
            
            self.configureAcceptedCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            cellArray3.append(cell)
            
            return cell

        }
        
        
    }
    func configureAcceptedCell(_ cell: AcceptedCell, forIndexPath indexPath: NSIndexPath){
    
    }
    func configureWantedCell(_ cell: WantedReceivedCell, forIndexPath indexPath: NSIndexPath){
        self.ref.child("users").child(auditReceivedArray[indexPath.row].userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if snap.key == "name"{
                        cell.artistNameLabel.text = snap.value as? String
                    }
                }
            }
            cell.indexPath = indexPath as IndexPath!
            cell.artistID = self.auditReceivedArray[indexPath.row].userID
            cell.bandNameLabel.text = self.auditReceivedArray[indexPath.row].bandName
            cell.artistImageView.loadImageUsingCacheWithUrlString(self.auditReceivedArray[indexPath.row].bandPicURL)
            cell.moreInfoTextView1.text = self.auditReceivedArray[indexPath.row].additInfo1
            cell.moreInfoTextView2.text = self.auditReceivedArray[indexPath.row].additInfo2
            cell.bandID = self.auditReceivedArray[indexPath.row].bandID
            cell.wantedID = self.auditReceivedArray[indexPath.row].wantedID
            cell.bandType = self.auditReceivedArray[indexPath.row].bandType
            cell.responseID = self.auditReceivedArray[indexPath.row].responseID
            
        })
    }
    func configureCell(_ cell: InviteCell, forIndexPath indexPath: NSIndexPath){
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
            cell.bandID = self.inviteArray[indexPath.row].bandID!
            cell.instrumentNeeded.text = self.inviteArray[indexPath.row].instrumentNeeded
            cell.indexPath = indexPath as IndexPath!
            cell.indexPathRow = indexPath.row
            //cell.curCell = cell
            cell.bandType = self.inviteArray[indexPath.row].bandType!
            cell.sessionDate.text = self.inviteArray[indexPath.row].date
            cell.sessionName.text = self.inviteArray[indexPath.row].bandName
            //cell.responseID = self.auditReceivedArray[indexPath.row].responseID
            
            if self.inviteArray[indexPath.row].bandType == "onb"{
            self.ref.child("bands").child(self.inviteArray[indexPath.row].bandID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                for snap in snapshots{
                    if snap.key == "bandBio"{
                        cell.sessionDescription.text = snap.value as? String
                    }
                
                    if snap.key == "bandPictureURL"{
                        cell.sessionImage.loadImageUsingCacheWithUrlString((snap.value as! [String]).first!)
                    }
                }
                
                
                
            })
            } else {
                self.ref.child("oneNightBands").child(self.inviteArray[indexPath.row].bandID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                    for snap in snapshots{
                        if snap.key == "onbInfo"{
                            cell.sessionDescription.text = snap.value as? String
                        }
                        
                        if snap.key == "onbPictureURL"{
                            cell.sessionImage.loadImageUsingCacheWithUrlString((snap.value as! [String]).first!)
                        }
                    }
                    
                    
                    
                })

            }
        })
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
