//
//  UploadSessionPopup.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/10/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import SwiftOverlays
//import Firebase




class UploadSessionPopup: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FeedDismissable {
    weak var feedDismissalDelegate: FeedDismissalDelegate?
    
    
    @IBOutlet weak var uploadToLiveFeedButton: UIButton!
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var feedPopupView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var sessionCollectionView: UICollectionView!
    
    var sessionArray = [Session]()

    var sessionIDArray = [String]()
    var selectedSession = Session()

    var ref = FIRDatabase.database().reference()
    var sizingCell: SessionCell?
    var selectedCellCount = 0
 
    @IBOutlet weak var yourBandsCollect: UICollectionView!
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var currentUserNameLabel: UILabel!
    @IBAction func currentUserButtonPressed(_ sender: Any) {
    }
       @IBOutlet weak var selectSessionLabel: UILabel!
    
    @IBOutlet weak var selectVideoLabel: UILabel!
    
    @IBOutlet weak var selectVideoFromSessionCollect: UICollectionView!
       func backToFeed(){
        //let vc = SessionFeedViewController()
        //present(vc, animated: true, completion: nil)
        performSegue(withIdentifier: "CancelPressed", sender: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        SwiftOverlays.removeAllBlockingOverlays()
    }
    var bandArray = [String]()
    var bandObjectArray = [Band]()
    var bandSessionIDArray = [String]()
    var bandSessionObjectArray = [Session]()
    var bandMedia = [NSURL]()
    var userMediaArray = [String]()
    var userMediaArrayNSURL = [NSURL]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.yourBandsCollect.isHidden = false
        self.selectSessionLabel.isHidden = true
        self.selectVideoLabel.isHidden = true
        self.sessionCollectionView.isHidden = true
        self.selectVideoFromSessionCollect.isHidden = true
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if snap.key == "profileImageURL"{
                        self.currentUserButton.imageView?.loadImageUsingCacheWithUrlString((snap.value as! [String]).first!)
                    }
                    if snap.key == "name"{
                        self.currentUserNameLabel.text = snap.value as! String
                    }
                    if snap.key == "media"{
                        let mediaSnaps = snap.children.allObjects as? [FIRDataSnapshot]
                        for m_snap in mediaSnaps!{
                            //fill youtubeArray
                            if m_snap.key == "youtube"{
                                for y_snap in m_snap.value as! [String]
                                {
                                    
                                    self.userMediaArrayNSURL.append(NSURL(string: y_snap)!)
                                    //self.nsurlArray.append(NSURL(string: y_snap)!)
                                    //self.nsurlDict[NSURL(string: y_snap)!] = "y"
                                }
                            }
                                //fill vidsFromPhone array
                            else{
                                for v_snap in m_snap.value as! [String]
                                {
                                    self.userMediaArrayNSURL.append(NSURL(string: v_snap)!)
                                    //self.nsurlArray.append(NSURL(string: v_snap)!)
                                    //self.nsurlDict[NSURL(string: v_snap)!] = "v"
                                }
                            }
                        }
                        //fill prof pic array
                    }
                    if snap.key == "artistsBands"{
                        for id in (snap.value as! [String]){
                            self.bandArray.append(id)
                        }
                    }
                }
            }
            

        
        self.ref.child("bands").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    let tempDict = snap.value as! [String:Any]
                    let tempBand = Band()
                    if self.bandArray.contains(snap.key){
                        tempBand.setValuesForKeys(tempDict)
                        self.bandObjectArray.append(tempBand)
                    }
                }
            }
           /* for band in self.bandObjectArray{
                for sess in band.bandSessions{
                    self.bandSessionIDArray.append(sess)
                }
            }*/
            DispatchQueue.main.async{
                for _ in self.bandArray{
                    self.currentCollect = "band"
                    
                    //self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                    
                    let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                    self.yourBandsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                    self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                    self.yourBandsCollect.backgroundColor = UIColor.clear
                    self.yourBandsCollect.dataSource = self
                    self.yourBandsCollect.delegate = self
                }
            }

        })
        })
       
                /*ref.child("sessions").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    let tempDict = snap.value as! [String:Any]
                    let tempBand = Session()
                    if self.bandSessionIDArray.contains(snap.key){
                        tempBand.setValuesForKeys(tempDict)
                        self.bandSessionObjectArray.append(tempBand)
                        /*let sessionSnaps = snap.children.allObjects as? [FIRDataSnapshot]
                        for sessSnap in sessionSnaps!{
                            if sessSnap.key == "sessionMedia"{
                                let mediaSnaps = sessSnap.children.allObjects as? [FIRDataSnapshot]
                        
                                for m_snap in mediaSnaps!{
                                    //fill youtubeArray
                                    if m_snap.key == "youtube"{
                                        for y_snap in m_snap.value as! [String]
                                        {
                                    
                                            self.bandMedia.append(NSURL(string: y_snap)!)
                                            //self.nsurlArray.append(NSURL(string: y_snap)!)
                                            //self.nsurlDict[NSURL(string: y_snap)!] = "y"
                                        }
                                    }
                                        //fill vidsFromPhone array
                                    else{
                                        for v_snap in m_snap.value as! [String]
                                        {
                                            self.userMediaArrayNSURL.append(NSURL(string: v_snap)!)
                                            //self.nsurlArray.append(NSURL(string: v_snap)!)
                                            //self.nsurlDict[NSURL(string: v_snap)!] = "v"
                                        }
                                    }
                                }
                        //fill prof pic array
                            }

                        }*/
                    }
                    
                    
                }
            }
        })*/


        navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.60)
        //let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(UploadSessionPopup.backToFeed))
        
       // navigationItem.leftBarButtonItem = backButton
        
        //sessionCollectionView.allowsSelection = true
        loadPastAndCurrentSessions()
        sessionCollectionView.visibleCells.first?.layer.borderWidth = 2
        sessionCollectionView.visibleCells.first?.layer.borderColor = UIColor.orange.cgColor
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(UploadSessionPopup.backToFeed))
        navigationItem.leftBarButtonItem = cancelButton
        
    }
    var currentCollect: String?
    let userID = FIRAuth.auth()?.currentUser?.uid
    func loadPastAndCurrentSessions(){
        
        //if(self.pastSessionsDidLoad == false){
        /*ref.child("users").child(userID!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    self.sessionIDArray.append((snap.value! as! String))
                }
                self.sessionCollectionView!.reloadData()
                
            }
            self.sessionCollectionView!.reloadData()
            self.ref.child("sessions").observeSingleEvent(of: .value, with: {(snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for id in self.sessionIDArray{
                    for snap in snapshots{
                        if snap.key == id{
                            let dictionary = snap.value as? [String: AnyObject]
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none
                            dateFormatter.dateStyle = DateFormatter.Style.short
                            let now = Date()
                            let order = Calendar.current.compare(now, to: self.dateFormatted(dateString: dictionary?["sessionDate"] as! String), toGranularity: .day)
                            
                            switch order {
                            case .orderedSame:
                                let tempSess = Session()
                                tempSess.setValuesForKeys(dictionary!)
                                self.sessionArray.append(tempSess)
                                
                            case .orderedAscending:
                                print("")
                                
                            case .orderedDescending:
                                let tempSess = Session()
                                tempSess.setValuesForKeys(dictionary!)
                                self.sessionArray.append(tempSess)
                                }
                            }
                        }
                    }
                }
                
                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                self.sessionCollectionView.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                self.sessionCollectionView.backgroundColor = UIColor.clear
                self.sessionCollectionView.dataSource = self
                self.sessionCollectionView.delegate = self
                self.sessionCollectionView!.reloadData()

                
                
            })
            

            
        })*/

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     if collectionView == yourBandsCollect{
        return bandArray.count
     }
        if collectionView == sessionCollectionView{
            return bandSessionObjectArray.count
        }
            else{
                return bandMedia.count
            }
        
     
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == yourBandsCollect || collectionView == sessionCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for:  indexPath as IndexPath) as! SessionCell
            self.configureCell(cell, collectionView, forIndexPath: indexPath as NSIndexPath)
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for:  indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureVidCell(cell, forIndexPath: indexPath as NSIndexPath)
            return cell
            
        }
    }
    
    
    
    
    //**
    //DidSelect
    //**
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.des
        if collectionView == yourBandsCollect{
            self.currentCollect = "band"
        }
        if collectionView == sessionCollectionView{
            self.currentCollect = "session"
        }
        if collectionView == selectVideoFromSessionCollect{
            self.currentCollect = "media"
        }
        if collectionView == yourBandsCollect{
           
            
            var bandCell = collectionView.cellForItem(at: indexPath) as! SessionCell
           self.selectVideoLabel.isHidden = true
            if bandCell.cellSelected == false{
                bandSessionObjectArray.removeAll()
                bandSessionIDArray.removeAll()
                bandCell.cellSelected = true
                for cell in collectionView.visibleCells{
                    if cell != bandCell {
                        //collectionView.deselectItem(at: collectionView.indexPath(for: cell)! , animated: true)
                        (cell as! SessionCell).cellSelected = false
                        (cell as! SessionCell).isSelected = false
                    }
                }
                    bandCell.layer.borderWidth = 2.0
                    bandCell.layer.borderColor = UIColor.orange.cgColor
                    //self.selectedSessionMediaArray.append(self.mostRecentSessionSelected)
                    bandCell.isSelected = true

                    self.sessionCollectionView.isHidden = false
                self.selectSessionLabel.isHidden = false
                    self.mostRecentBandSelected = bandObjectArray[indexPath.row]
                    for sess in self.mostRecentBandSelected.bandSessions{
                        self.bandSessionIDArray.append(sess)
                    }
                    ref.child("sessions").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            print("inside ref")
                            for snap in snapshots{
                                let tempDict = snap.value as! [String:Any]
                                let tempSess = Session()
                                if self.bandSessionIDArray.contains(snap.key){
                                    tempSess.setValuesForKeys(tempDict)
                                    self.bandSessionObjectArray.append(tempSess)
                                        }
                
                
                            }
                        }
                        DispatchQueue.main.async{
                            for _ in self.bandSessionObjectArray{
                                self.currentCollect = "session"
                        
                                //self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                        
                                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                self.sessionCollectionView.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                self.sessionCollectionView.backgroundColor = UIColor.clear
                                self.sessionCollectionView.dataSource = self
                                self.sessionCollectionView.delegate = self
                            }
                            collectionView.deselectItem(at: indexPath as IndexPath, animated: false)
                            self.yourBandsCollect.reloadData()
                            self.sessionCollectionView.reloadData()
                            self.selectVideoFromSessionCollect.reloadData()
                        }
                    })
            }
            else{
                bandCell.cellSelected = false
                self.sessionCollectionView.isHidden = true
                self.selectSessionLabel.isHidden = true
                self.bandSessionObjectArray.removeAll()
                self.bandSessionIDArray.removeAll()
                
                self.selectVideoFromSessionCollect.isHidden = true
                self.selectVideoLabel.isHidden = true
                self.bandMedia.removeAll()
                self.selectedSessionMediaArray.removeAll()
                //let cell = collectionView.cellForItem(at: indexPath) as! SessionCell
                bandCell.layer.borderColor = UIColor.clear.cgColor
                bandCell.isSelected = false
               

            }
           
            
        
        
        

            }
        
        if collectionView == sessionCollectionView{
            self.selectVideoLabel.isHidden = false
            let sessCell = collectionView.cellForItem(at: indexPath) as! SessionCell
            if sessCell.cellSelected == false{
                sessCell.cellSelected = true
                bandMedia.removeAll()
    
            sessCell.layer.borderWidth = 2.0
            sessCell.layer.borderColor = UIColor.orange.cgColor
            //self.selectedSessionMediaArray.append(self.mostRecentSessionSelected)
            sessCell.isSelected = true
            
            for cell in collectionView.visibleCells{
                if cell != sessCell {
                    //collectionView.deselectItem(at: collectionView.indexPath(for: cell)! , animated: true)
                    (cell as! SessionCell).cellSelected = false
                    (cell as! SessionCell).isSelected = false
                }
            }

            self.selectVideoFromSessionCollect.isHidden = false
            self.mostRecentSessionSelected = bandSessionObjectArray[indexPath.row]
            ref.child("sessions").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if ((snap.value as! [String:Any])["bandID"] as! String) == self.mostRecentBandSelected.bandID{
                            let sessionSnaps = snap.children.allObjects as? [FIRDataSnapshot]
                            for sessSnap in sessionSnaps!{
                                if sessSnap.key == "sessionMedia"{
                                    let mediaSnaps = sessSnap.children.allObjects as? [FIRDataSnapshot]
 
                                    for m_snap in mediaSnaps!{
                                        //fill youtubeArray
                                        if m_snap.key == "youtube"{
                                            for y_snap in m_snap.value as! [String]
                                            {
 
                                                self.bandMedia.append(NSURL(string: y_snap)!)
                                                //self.nsurlArray.append(NSURL(string: y_snap)!)
                                                //self.nsurlDict[NSURL(string: y_snap)!] = "y"
                                            }
                                        }
                                            //fill vidsFromPhone array
                                        else{
                                            for v_snap in m_snap.value as! [String]
                                            {
                                                self.bandMedia.append(NSURL(string: v_snap)!)
                                                //self.nsurlArray.append(NSURL(string: v_snap)!)
                                                //self.nsurlDict[NSURL(string: v_snap)!] = "v"
                                            }
                                        }
                                    }
                                    //fill prof pic array
                                }
 
                            }
                        }
                    }
                }
                DispatchQueue.main.async{
                    for _ in self.bandMedia{
                        self.currentCollect = "media"
                        
                        //self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                        
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.selectVideoFromSessionCollect.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.selectVideoFromSessionCollect.backgroundColor = UIColor.clear
                        self.selectVideoFromSessionCollect.dataSource = self
                        self.selectVideoFromSessionCollect.delegate = self
                        
                    }
                    collectionView.deselectItem(at: indexPath as IndexPath, animated: false)
                    //collectionView.visibleCells[indexPath.row] as Session = !collectionView.visibleCells[indexPath.row].selected
                    //self.yourBandsCollect.reloadData()
                    self.sessionCollectionView.reloadData()
                    self.selectVideoFromSessionCollect.reloadData()
                    
                }

            })
            }
            else{
                sessCell.cellSelected = false
                self.selectVideoFromSessionCollect.isHidden = true
                self.bandMedia.removeAll()
                selectedSessionMediaArray.removeAll()
                //let cell = collectionView.cellForItem(at: indexPath) as! SessionCell
                sessCell.layer.borderColor = UIColor.clear.cgColor
                sessCell.isSelected = false
               /* DispatchQueue.main.async{
                    //self.yourBandsCollect.reloadData()
                    //self.sessionCollectionView.reloadData()
                    self.selectVideoFromSessionCollect.reloadData()
                }*/
            }
    
            
        }
        if collectionView == selectVideoFromSessionCollect{
 
 
            var cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
            if cell.cellSelected == false{
                cell.cellSelected = true
    
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = UIColor.orange.cgColor
                self.selectedSessionMediaArray.append(bandMedia[indexPath.row])
                cell.isSelected = true
                cell.playPauseButton.isEnabled = false
            }else{
                cell.cellSelected = false
                let cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.isSelected = false
                //could cause problems
                
                self.selectedSessionMediaArray.remove(at: indexPath.row)
            }
    
            
        
        }
        
    
    //collectionView.reloadData()
        
        
    }
    
    var selectedSessionMediaArray = [NSURL]()
    var sizingCell2 = VideoCollectionViewCell()
    var mostRecentSessionSelected = Session()
    var mostRecentBandSelected = Band()
    
    
    /*public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath){
        print("deselcet")
        if collectionView == self.yourBandsCollect{
            self.sessionCollectionView.isHidden = true
            self.bandSessionObjectArray.removeAll()
            self.bandSessionIDArray.removeAll()
            
            self.selectVideoFromSessionCollect.isHidden = true
            self.bandMedia.removeAll()
            self.selectedSessionMediaArray.removeAll()
            let cell = collectionView.cellForItem(at: indexPath) as! SessionCell
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.isSelected = false

            
        }
        if collectionView == self.sessionCollectionView{
            self.selectVideoFromSessionCollect.isHidden = true
            self.bandMedia.removeAll()
            selectedSessionMediaArray.removeAll()
            let cell = collectionView.cellForItem(at: indexPath) as! SessionCell
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.isSelected = false

        }
        else{
        let cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.isSelected = false
        //could cause problems
            
        self.selectedSessionMediaArray.remove(at: indexPath.row)
        }
    }*/

    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        if bandMedia.count == 0{
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 2
            cell.removeVideoButton.isHidden = true
            cell.videoURL = nil
            cell.player?.view.isHidden = true
            cell.youtubePlayerView.isHidden = true
            //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
            cell.removeVideoButton.isHidden = true
            cell.noVideosLabel.isHidden = false
        }else {
            
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
            
            //cell.youtubePlayerView.isHidden = true
            cell.removeVideoButton.isHidden = true
            cell.noVideosLabel.isHidden = true
            
            
            
            cell.videoURL =  self.bandMedia[indexPath.row] as NSURL?
            if(String(describing: cell.videoURL).contains("youtube") || String(describing: cell.videoURL).contains("youtu.be")){
                cell.youtubePlayerView.loadVideoURL(cell.videoURL as! URL)
                cell.youtubePlayerView.isHidden = false
                cell.player?.view.isHidden = true
                cell.isYoutube = true
            }else{
                cell.player?.setUrl(cell.videoURL as! URL)
                cell.player?.view.isHidden = false
                cell.youtubePlayerView.isHidden = true
                cell.isYoutube = false
            }
            //print(self.vidArray[indexPath.row])
            //cell.youtubePlayerView.loadVideoURL(self.vidArray[indexPath.row] as URL)
            //self.group.leave()
        }
        

    }
    func configureCell(_ cell: SessionCell,_ collectionView: UICollectionView, forIndexPath indexPath: NSIndexPath) {
        //print(self.currentCollect)
        if collectionView == self.yourBandsCollect{
            print(bandObjectArray[indexPath.row].bandPictureURL[0])
            //print(bandObjectArray)
            cell.sessionCellImageView.loadImageUsingCacheWithUrlString(bandObjectArray[indexPath.row].bandPictureURL[0])
            cell.sessionCellLabel.text = bandObjectArray[indexPath.row].bandName
            cell.sessionCellLabel.textColor = UIColor.white
            cell.layer.borderWidth = cell.cellSelected ? 2 : 0
            cell.layer.borderColor = cell.cellSelected ? UIColor.orange.cgColor : UIColor.clear.cgColor
            
            cell.sessionId = bandArray[indexPath.row]

        }
        if collectionView == self.sessionCollectionView{
        cell.sessionCellImageView.loadImageUsingCacheWithUrlString(bandSessionObjectArray[indexPath.row].sessionPictureURL[0])
        cell.sessionCellLabel.text = bandSessionObjectArray[indexPath.row].sessionName
        cell.sessionCellLabel.textColor = UIColor.white
        cell.layer.borderWidth = cell.cellSelected ? 2 : 0
        cell.layer.borderColor = cell.cellSelected ? UIColor.orange.cgColor : UIColor.clear.cgColor

        cell.sessionId = bandSessionIDArray[indexPath.row]
        }
        if collectionView == self.selectVideoFromSessionCollect{
            cell.sessionCellImageView.loadImageUsingCacheWithUrlString(bandSessionObjectArray[indexPath.row].sessionPictureURL[0])
            cell.sessionCellLabel.text = bandSessionObjectArray[indexPath.row].sessionName
            cell.sessionCellLabel.textColor = UIColor.white
            cell.layer.borderWidth = cell.cellSelected ? 2 : 0
            cell.layer.borderColor = cell.cellSelected ? UIColor.orange.cgColor : UIColor.clear.cgColor
            
            cell.sessionId = bandSessionIDArray[indexPath.row]
        }
        
        }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        /*if sessionBioTextView.textColor == UIColor.gray {
            sessionBioTextView.text = nil
            sessionBioTextView.textColor = UIColor.orange
        }*/
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        /*if sessionBioTextView.text.isEmpty {
            sessionBioTextView.text = "tap to add a little info about the type of session you are trying to create."
            sessionBioTextView.textColor = UIColor.gray
        }*/
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    @IBAction func cancelTouched(_ sender: AnyObject) {
        feedDismissalDelegate?.finishedShowing(viewController: self)

        removeAnimate()
    }
    /*@IBAction func finalizeTouched(_ sender: AnyObject) {
        if(sessionImageView.image != nil && sessionNameTextField.text != "" && sessionBioTextView.text != "tap to add a little info about the type of session you are trying to create."){
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("session_images").child("\(imageName).jpg")
            
            if let sessionImage = self.sessionImageView.image, let uploadData = UIImageJPEGRepresentation(sessionImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if let sessionImageUrl = metadata?.downloadURL()?.absoluteString {
                        var tempArray = [String]()
                        var tempArray2 = [String]()
                        var values = Dictionary<String, Any>()
                        tempArray2.append((FIRAuth.auth()?.currentUser?.uid)! as String)
                        values["sessionName"] =  self.sessionNameTextField.text
                        values["sessionArtists"] = tempArray2
                        values["sessionBio"] = self.sessionBioTextView.text
                        values["sessionPictureURL"] = sessionImageUrl
                        values["sessionMedia"] = ""
                        let dateformatter = DateFormatter()
                        
                        dateformatter.dateStyle = DateFormatter.Style.short
                        
                        //dateformatter.timeStyle = DateFormatter.Style.short
                        
                        let now = dateformatter.string(from: self.datePicker.date)
                        values["sessionDate"] = now
                        
                        
                        let ref = FIRDatabase.database().reference()
                        let sessReference = ref.child("sessions").childByAutoId()
                        
                        let sessReferenceAnyObject = sessReference.key
                        values["sessionUID"] = sessReferenceAnyObject
                        tempArray.append(sessReferenceAnyObject)
                        //print(sessReference.key)
                        //sessReference.childByAutoId()
                        sessReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if err != nil {
                                print(err)
                                return
                            }
                        })
                        let user = FIRAuth.auth()?.currentUser?.uid
                        //var sessionVals = Dictionary
                        //let userSessRef = ref.child("users").child(user).child("activeSessions")
                        self.ref.child("users").child(user!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                for snap in snapshots{
                                    tempArray.append(snap.value! as! String)
                                }
                            }
                            var tempDict = [String : Any]()
                            tempDict["activeSessions"] = tempArray
                            let userRef = ref.child("users").child(user!)
                            userRef.updateChildValues(tempDict, withCompletionBlock: {(err, ref) in
                                if err != nil {
                                    print(err)
                                    return
                                }
                            })
                            self.dismissalDelegate?.finishedShowing(viewController: self)
                            self.removeAnimate()
                            //this is ridiculously stupid way to reload currentSession data. find someway to fix
                            self.performSegue(withIdentifier: "FinalizeSessionToProfile", sender: self)
                            self.performSegue(withIdentifier: "CreateSessionPopupToCurrentSession", sender: self)
                        })
                    }
                })
            }
            
            
        }else{
            let alert = UIAlertController(title: "Error", message: "Missing Information", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }*/
    
    func dateFormatted(dateString: String)->Date{
        
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd-MM-yy"
        
        dateFormatter.dateFormat = "MM-dd-yy"
        //        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateObj = dateFormatter.date(from: dateString)
        
        
        return(dateObj)!
        
    }
    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    
    
    
    /*@IBAction func addMediaSelected(_ sender: AnyObject) {
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.delegate = self
        
        
        present(imagePickerController, animated: true, completion: nil)

    }*/
       
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL
        print(videoURL)
        print("picker done")
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }*/

    var sessionVideoURL: String?
    var downloadURL: URL?
    var mediaArray = [String]()
    var autoIdString = String()
    @IBAction func Upload(_ sender: AnyObject) {
        if movieURLFromPicker != nil{
            SwiftOverlays.showBlockingTextOverlay("Uploading Session to Feed")
            uploadMovieToFirebaseStorage(url: movieURLFromPicker!)
        }else{
            let alert = UIAlertController(title: "No Session Selected", message: "Select one of the above sessions. Only Sessions that you played in will show up.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func uploadMovieToFirebaseStorage(url: NSURL){
        let videoName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference(withPath: "session_videos").child("\(videoName).mov")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "video/quicktime"
        let uploadTask = storageRef.putFile(url as URL, metadata: uploadMetadata){(metadata, error) in
            if(error != nil){
                print("got an error: \(error)")
            }else{
                print("upload complete: metadata = \(metadata)")
                print("download url = \(metadata?.downloadURL())")
                let recipient = self.ref.child("sessionFeed")
                let recipient2 = self.ref.child("sessions").child(self.selectedSession.sessionUID!)
                print(self.selectedSession)
                for cell in self.sessionCollectionView.visibleCells{
                    if cell.isSelected == true{
                        print("isSelected")
                        FIRDatabase.database().reference().child("sessionFeed").observeSingleEvent(of: .value, with:
                            { (snapshot) in
                                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                    print("inside snapshot: \(snapshots)")
                                    var values = Dictionary<String, Any>()
                                    var values2 = Dictionary<String, Any>()
                                    
                                        values["sessionName"] = self.selectedSession.sessionName
                                        values["sessionArtists"] = self.selectedSession.sessionArtists
                                        values["sessionBio"] = self.selectedSession.sessionBio
                                        values["sessionDate"] = self.selectedSession.sessionDate
                                        values["sessionUID"] = self.selectedSession.sessionUID
                                        values["sessionPictureURL"] = self.selectedSession.sessionPictureURL
                                    values["views"] = 0
                                        // values["sessionMedia"] = metadata?.downloadURL()?.absoluteString
                                        
                                        //values2["sessionMedia"] = metadata?.downloadURL()?.absoluteString
                                        
                                        let currentUser = FIRAuth.auth()?.currentUser?.uid
                                        FIRDatabase.database().reference().child("users").child(currentUser!).child("sessionMedia").observeSingleEvent(of: .value, with: { (snapshot) in
                                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                                for snap in snapshots{
                                                    self.mediaArray.append(snap.value! as! String)
                                                }
                                                self.mediaArray.append((metadata?.downloadURL()?.absoluteString)!)
                                                var tempArray = [String]()
                                                tempArray.append((metadata?.downloadURL()?.absoluteString)!)
                                                values["sessionMedia"] = tempArray
                                                values2["sessionMedia"] = self.mediaArray
                                                let autoId = recipient.childByAutoId()
                                                //self.autoIdString = String(describing: autoId)
                                                autoId.updateChildValues(values, withCompletionBlock: {(err, ref) in
                                                    if err != nil {
                                                        print(err as Any)
                                                        return
                                                    }
                                                })
                                                recipient2.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                                                    if err != nil {
                                                        print(err)
                                                        return
                                                    }
                                                    self.performSegue(withIdentifier: "CancelPressed", sender: self)
                                                })
                                            }
                                        })
                                        

                                    
                                    for snap in snapshots{
                                        let tempDict = snap.value as! [String: Any]
                                        if tempDict["sessionUID"] as! String == self.selectedSession.sessionUID! as String{
                                            
                                            
                                        FIRDatabase.database().reference().child("sessions").child(self.selectedSession.sessionUID! as String).child("sessFeedKeys").observeSingleEvent(of: .value, with: {(snapshot) in
                                                var sessFeedKeyArray = snapshot.value as! [String]
                                     sessFeedKeyArray.append(self.autoIdString)
                                           values["sessFeedKeys"] = sessFeedKeyArray
                                     
                                     
                                            recipient2.updateChildValues(values, withCompletionBlock: {(err, ref) in
                                                if err != nil {
                                                    print(err as Any)
                                                    return
                                                }
                                            })
                                            
                                            
                                            
                                            })
                                        }
                                        
                                    }
                                    }
                                
                        })
                    }
            
                }

            }
    }
        /*uploadTask.observe(.progress){[weak self] (snapshot) in
            guard let strongSelf = self else {return}
            guard let progress = snapshot.progress else {return}
            strongSelf.progressView.progress = Float(progress.fractionCompleted)
            print("Uploaded \(progress.completedUnitCount) so far")
        }*/
    }
    var movieURLFromPicker: NSURL?
    
}

extension UploadSessionPopup: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        //guard let mediaType: String = info[UIImagePickerControllerMediaType] as? String else {
        //    dismiss(animated: true, completion: nil)
        //    return
            
       // }
        //if mediaType ==  "public.movie"{
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                movieURLFromPicker = movieURL
                dismiss(animated: true, completion: nil)
                //uploadMovieToFirebaseStorage(url: movieURL)
            }
            
        //}
    }
    
    @available(iOS 2.0, *)
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
        
    }
}



