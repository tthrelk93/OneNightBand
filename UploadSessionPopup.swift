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




class UploadSessionPopup: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FeedDismissable, UITextViewDelegate {
    weak var feedDismissalDelegate: FeedDismissalDelegate?
    
    @IBOutlet weak var soloImageView: UIImageView!
    
    @IBOutlet weak var uploadToLiveFeedButton: UIButton!
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var feedPopupView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var sessionCollectionView: UICollectionView!
    
    var sessionArray = [Session]()

    var sessionIDArray = [String]()
    var selectedSession = Session()
    var soloPickerUsed = false

    @IBOutlet weak var soloSessionNameTextView: UITextField!
    @IBOutlet weak var soloSessTextView: UITextView!
    @IBOutlet weak var soloPicker: UIView!
    @IBAction func cancelSoloPickerPressed(_ sender: Any) {
        self.soloPicker.isHidden = true
        self.soloPickerUsed = false
        self.yourBandsCollect.isHidden = false
        /*self.sessionCollectionView.isHidden = true
        self.selectVideoFromSessionCollect = true*/
        self.uploadBandToFeed.isHidden = false
        //self.soloImageView.isHidden = false
        //self.currentUserNameLabel.isHidden = false
       

    }
    @IBOutlet weak var uploadBandToFeed: UIButton!
    @IBOutlet weak var soloPicCollect: UICollectionView!
    @IBOutlet weak var soloVidCollect: UICollectionView!
    var ref = Database.database().reference()
    var sizingCell: SessionCell?
    var selectedCellCount = 0
 
    @IBOutlet weak var yourBandsCollect: UICollectionView!
    @IBOutlet weak var currentUserButton: UIButton!
    @IBOutlet weak var currentUserNameLabel: UILabel!
    @IBAction func currentUserButtonPressed(_ sender: Any) {
        self.soloPicker.isHidden = false
        self.soloPickerUsed = true
        self.yourBandsCollect.isHidden = true
        self.sessionCollectionView.isHidden = true
        self.selectVideoFromSessionCollect.isHidden = true
        self.uploadBandToFeed.isHidden = true
        self.soloImageView.isHidden = true
        self.currentUserNameLabel.isHidden = true
        
        
    }
       @IBOutlet weak var selectSessionLabel: UILabel!
    
    @IBOutlet weak var selectVideoLabel: UILabel!
    var onbArray = [String]()
    @IBOutlet weak var selectVideoFromSessionCollect: UICollectionView!
       func backToFeed(){
        //let vc = SessionFeedViewController()
        //present(vc, animated: true, completion: nil)
        performSegue(withIdentifier: "CancelPressed", sender: self)
    }
    var onbObjectArray = [ONB]()
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
    var soloPicArray2 = [NSURL]()
    var soloPicArray = [String]()
    
    var soloPicURLArray = [UIImage]()
    var soloVidURLArray = [NSURL]()
    
    var selectedSoloVidArray = [NSURL]()
    var selectedSoloPicArray = [UIImage]()
    var selectedSoloPicURL = [NSURL]()
    let ONBPink = UIColor(colorLiteralRed: 201.0/255.0, green: 38.0/255.0, blue: 92.0/255.0, alpha: 1.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalMediaBounds = selectVideoFromSessionCollect.frame
        self.soloSessTextView.delegate = self
        self.soloPicker.isHidden = true
        self.yourBandsCollect.isHidden = true
        self.onbCollect.isHidden = true
        self.selectSessionLabel.isHidden = true
        self.selectVideoLabel.isHidden = true
        self.sessionCollectionView.isHidden = true
        self.selectVideoFromSessionCollect.isHidden = true
        
        //self.soloSessTextView
        self.soloSessTextView.text = "Give a little background on the session you are uploading."
        self.soloSessTextView.textColor = ONBPink
        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    if snap.key == "media"{
                        let mediaSnaps = snap.value as! [String]
                        for m_snap in mediaSnaps{
                            //fill youtubeArray
                            self.soloVidURLArray.append(NSURL(string: m_snap)!)
                            self.userMediaArrayNSURL.append(NSURL(string: m_snap)!)
                                    //self.nsurlArray.append(NSURL(string: y_snap)!)
                                    //self.nsurlDict[NSURL(string: y_snap)!] = "y"
                            
                                //fill vidsFromPhone array
                           
                        }
                    }
                        //fill prof pic array
    
                    if snap.key == "artistsBands"{
                        for id in (snap.value as! [String]){
                            self.bandArray.append(id)
                        }
                    }
                    if snap.key == "artistsONBs"{
                        for id in (snap.value as! [String]){
                            self.onbArray.append(id)
                        }
                    }
                }
            }
            
            self.ref.child("oneNightBands").observeSingleEvent(of: .value, with: {(snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots{
                        let tempDict = snap.value as! [String:Any]
                        let tempONB = ONB()
                        if self.onbArray.contains(snap.key){
                            tempONB.setValuesForKeys(tempDict)
                            self.onbObjectArray.append(tempONB)
                        }
                    }
                }
                
            
            

        
        self.ref.child("bands").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
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
                
                for _ in self.onbArray{
                    self.currentCollect = "onb"
                    
                    //self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                    
                    let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                    self.onbCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                    self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                    self.onbCollect.backgroundColor = UIColor.clear
                    self.onbCollect.dataSource = self
                    self.onbCollect.delegate = self
                }
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
                for vid in self.soloVidURLArray{
                    self.currentCollect = "soloVid"
                    
                    //self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                    
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.soloVidCollect.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.soloVidCollect.backgroundColor = UIColor.clear
                    self.soloVidCollect.dataSource = self
                    self.soloVidCollect.delegate = self
                }
                for picString in self.soloPicArray{
                    if let tempUrl = NSURL(string: picString){
                        self.soloPicArray2.append(tempUrl)
                        if let data = NSData(contentsOf: tempUrl as URL){
                            self.soloPicURLArray.append(UIImage(data: data as Data)!)
                        }
                    }

                }
                for pic in self.soloPicURLArray{
                    self.currentCollect = "soloPic"
                    
                    //self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                    
                    let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                    self.soloPicCollect.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                    self.sizingCell3 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                    self.soloPicCollect.backgroundColor = UIColor.clear
                    self.soloPicCollect.dataSource = self
                    self.soloPicCollect.delegate = self
                }
            }

        })
        })
        })
       
               

        navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.60)
        //let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(UploadSessionPopup.backToFeed))
        
       // navigationItem.leftBarButtonItem = backButton
        
        //sessionCollectionView.allowsSelection = true
        //loadPastAndCurrentSessions()
        sessionCollectionView.visibleCells.first?.layer.borderWidth = 2
        sessionCollectionView.visibleCells.first?.layer.borderColor = ONBPink.cgColor
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(UploadSessionPopup.backToFeed))
        navigationItem.leftBarButtonItem = cancelButton
        
    }
    var sizingCell3 = PictureCollectionViewCell()
    var currentCollect: String?
    let userID = Auth.auth().currentUser?.uid
    func loadPastAndCurrentSessions(){
        
        //if(self.pastSessionsDidLoad == false){
        /*ref.child("users").child(userID!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots{
                    self.sessionIDArray.append((snap.value! as! String))
                }
                self.sessionCollectionView!.reloadData()
                
            }
            self.sessionCollectionView!.reloadData()
            self.ref.child("sessions").observeSingleEvent(of: .value, with: {(snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
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
        if collectionView == onbCollect{
            return onbArray.count
        }
        if collectionView == sessionCollectionView{
            return bandSessionObjectArray.count
        }
        if collectionView == selectVideoFromSessionCollect{
                return bandMedia.count
            }
        if collectionView == soloVidCollect{
            return soloVidURLArray.count
        }
        else {
            return soloPicURLArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == yourBandsCollect || collectionView == sessionCollectionView || collectionView == onbCollect{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for:  indexPath as IndexPath) as! SessionCell
            self.configureCell(cell, collectionView, forIndexPath: indexPath as NSIndexPath)
            return cell
        }
        else if collectionView == soloVidCollect || collectionView == selectVideoFromSessionCollect{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for:  indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureVidCell(cell, forIndexPath: indexPath as NSIndexPath)
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for:  indexPath as IndexPath) as! PictureCollectionViewCell
            self.configurePicCell(cell, forIndexPath: indexPath as NSIndexPath)
            return cell

        }
    }
    
    
    
    @IBOutlet weak var onbCollect: UICollectionView!
    
    //**
    //DidSelect
    //**
    //var onbVideoArray = [String]()
    var originalMediaBounds = CGRect()
    var mostRecentONBSelected = ONB()
    var onbMediaArray = [String]()
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.des
        if collectionView == yourBandsCollect{
            self.currentCollect = "band"
        }
        if collectionView == onbCollect{
            self.currentCollect = "onb"
        }
        if collectionView == sessionCollectionView{
            self.currentCollect = "session"
        }
        if collectionView == selectVideoFromSessionCollect{
            self.currentCollect = "media"
        }
        if collectionView == soloPicCollect{
            self.currentCollect = "soloPic"
        }
        if collectionView == soloVidCollect{
            self.currentCollect = "soloVid"
        }
        ref.child("sessions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //if band collection view cell is touched
            if collectionView == self.onbCollect{
                var bandCell = collectionView.cellForItem(at: indexPath) as! SessionCell
                self.selectVideoLabel.isHidden = true
                if bandCell.cellSelected == false{
                    //self.bandSessionObjectArray.removeAll()
                    //self.bandSessionIDArray.removeAll()
                    bandCell.cellSelected = true
                    for cell in collectionView.visibleCells{
                        if cell != bandCell {
                            //collectionView.deselectItem(at: collectionView.indexPath(for: cell)! , animated: true)
                            (cell as! SessionCell).cellSelected = false
                            (cell as! SessionCell).isSelected = false
                        }
                    }
                    bandCell.layer.borderWidth = 2.0
                    bandCell.layer.borderColor = self.ONBPink.cgColor
                    //self.selectedSessionMediaArray.append(self.mostRecentSessionSelected)
                    bandCell.isSelected = true
                    
                    //self.sessionCollectionView.isHidden = false
                    //self.selectSessionLabel.isHidden = false
                    self.mostRecentONBSelected = self.onbObjectArray[indexPath.row]
                    self.bandType = "onb"
                    for vid in self.mostRecentONBSelected.onbMedia{
                        self.onbMediaArray.append(vid)
                    }
                        DispatchQueue.main.async{
                        for _ in self.onbMediaArray{
                            self.currentCollect = "media"
                            
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.selectVideoFromSessionCollect.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.selectVideoFromSessionCollect.backgroundColor = UIColor.clear
                            self.selectVideoFromSessionCollect.dataSource = self
                            self.selectVideoFromSessionCollect.delegate = self
                            }
                        collectionView.deselectItem(at: indexPath as IndexPath, animated: false)
                        self.onbCollect.reloadData()
                        self.selectVideoFromSessionCollect.reloadData()
                        //self.selectVideoFromSessionCollect.reloadData()
                    }
                    
                }
                else{
                    bandCell.cellSelected = false
                    self.sessionCollectionView.isHidden = true
                    self.selectSessionLabel.isHidden = true
                    self.onbMediaArray.removeAll()
                    //self.bandSessionIDArray.removeAll()
                    
                    self.selectVideoFromSessionCollect.isHidden = true
                    self.selectVideoLabel.isHidden = true
                    self.bandMedia.removeAll()
                    self.selectedSessionMediaArray.removeAll()
                    //let cell = collectionView.cellForItem(at: indexPath) as! SessionCell
                    bandCell.layer.borderColor = UIColor.clear.cgColor
                    bandCell.isSelected = false
                }
            }

            if collectionView == self.yourBandsCollect{
                self.selectVideoFromSessionCollect.frame = self.sessionCollectionView.frame
                var bandCell = collectionView.cellForItem(at: indexPath) as! SessionCell
                self.selectVideoLabel.isHidden = true
                if bandCell.cellSelected == false{
                    self.bandSessionObjectArray.removeAll()
                    self.bandSessionIDArray.removeAll()
                    bandCell.cellSelected = true
                    for cell in collectionView.visibleCells{
                        if cell != bandCell {
                            //collectionView.deselectItem(at: collectionView.indexPath(for: cell)! , animated: true)
                            (cell as! SessionCell).cellSelected = false
                            (cell as! SessionCell).isSelected = false
                        }
                    }
                        bandCell.layer.borderWidth = 2.0
                        bandCell.layer.borderColor = self.ONBPink.cgColor
                        //self.selectedSessionMediaArray.append(self.mostRecentSessionSelected)
                        bandCell.isSelected = true

                        self.sessionCollectionView.isHidden = false
                    self.selectSessionLabel.isHidden = false
                    self.mostRecentBandSelected = self.bandObjectArray[indexPath.row]
                    self.bandType = "band"
                    for sess in self.mostRecentBandSelected.bandSessions{
                        self.bandSessionIDArray.append(sess)
                    }
                
                        if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                            print("inside ref")
                            for snap in snapshots{
                                let tempDict = snap.value as! [String:Any]
                                let tempSess = Session()
                                if self.bandSessionIDArray.contains(snap.key){
                                    tempSess.setValuesForKeys(tempDict)
                                    self.bandSessionObjectArray.append(tempSess)
                                        }
                                self.bandSessionObjectArray.reverse()
                
                
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
                            //self.selectVideoFromSessionCollect.reloadData()
                    }
                
                }
                else{
                    bandCell.cellSelected = false
                    self.sessionCollectionView.isHidden = true
                    self.selectSessionLabel.isHidden = true
                    self.bandSessionObjectArray.removeAll()
                    self.bandSessionIDArray.removeAll()
                    
                    self.selectVideoFromSessionCollect.frame = self.originalMediaBounds
                
                    self.selectVideoFromSessionCollect.isHidden = true
                    self.selectVideoLabel.isHidden = true
                    self.bandMedia.removeAll()
                    self.selectedSessionMediaArray.removeAll()
                    //let cell = collectionView.cellForItem(at: indexPath) as! SessionCell
                    bandCell.layer.borderColor = UIColor.clear.cgColor
                    bandCell.isSelected = false
                }
            }
        //if session collection view cell is touched
        if collectionView == self.sessionCollectionView{
            self.selectVideoLabel.isHidden = false
            let sessCell = collectionView.cellForItem(at: indexPath) as! SessionCell
            if sessCell.cellSelected == false{
                sessCell.cellSelected = true
                self.bandMedia.removeAll()
    
            sessCell.layer.borderWidth = 2.0
            sessCell.layer.borderColor = self.ONBPink.cgColor
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
            self.mostRecentSessionSelected = self.bandSessionObjectArray[indexPath.row]
                
                for sess in self.bandSessionObjectArray{
                    if sess.sessionUID == sessCell.sessionId {
                        if sess.sessionMedia.count != 0{
                            //if (sess.sessionMedia.keys.contains("youtube")){
                            
                                for vid in sess.sessionMedia{
                                    self.bandMedia.append(NSURL(string: vid)!)
                                }
                            }
                            /*if (sess.sessionMedia.keys.contains("vidsFromPhone")){
                            
                            let tempMediaArray2 = sess.sessionMedia["vidsFromPhone"] as! [String]
                            for vid in tempMediaArray2{
                                self.bandMedia.append(NSURL(string: vid)!)
                            }
                    }
                    }*/
                    
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
            }
                
            else{
                sessCell.cellSelected = false
                self.selectVideoFromSessionCollect.isHidden = true
                self.bandMedia.removeAll()
                self.selectedSessionMediaArray.removeAll()
                //let cell = collectionView.cellForItem(at: indexPath) as! SessionCell
                sessCell.layer.borderColor = UIColor.clear.cgColor
                sessCell.isSelected = false
              
            }
        }
        //if media cell selected
        if collectionView == self.selectVideoFromSessionCollect{
            let cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
            if cell.cellSelected == false{
                cell.cellSelected = true
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = self.ONBPink.cgColor
                self.selectedSessionMediaArray.append(self.bandMedia[indexPath.row])
                cell.isSelected = true
                cell.playPauseButton.isEnabled = false
            }else{
                cell.cellSelected = false
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.isSelected = false
                
                //could cause problems
                self.selectedSessionMediaArray.remove(at: indexPath.row)
            }
            print(self.selectedSessionMediaArray)
    
            
        
            }
        })
        if collectionView == soloPicCollect{
            let cell = collectionView.cellForItem(at: indexPath) as! PictureCollectionViewCell
            if cell.cellSelected == false{
                cell.cellSelected = true
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = ONBPink.cgColor
                self.selectedSoloPicArray.append(self.soloPicURLArray[indexPath.row])
                selectedSoloPicURL.append(self.soloPicArray2[indexPath.row])
                cell.isSelected = true
            } else{
                cell.cellSelected = false
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.isSelected = false
                self.selectedSoloPicArray.remove(at: indexPath.row)
                selectedSoloPicURL.remove(at: indexPath.row)

            }

            
        }
        if collectionView == soloVidCollect{
            let cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
            if cell.cellSelected == false{
                cell.cellSelected = true
                cell.layer.borderWidth = 2.0
                cell.layer.borderColor = ONBPink.cgColor
                self.selectedSoloVidArray.append(self.soloVidURLArray[indexPath.row])
                cell.isSelected = true
            } else{
                cell.cellSelected = false
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.isSelected = false
                self.selectedSoloVidArray.remove(at: indexPath.row)
                
            }
            
            
        }

        
    
    //collectionView.reloadData()
        
        
    }
    
    var selectedSessionMediaArray = [NSURL]()
    var sizingCell2 = VideoCollectionViewCell()
    var mostRecentSessionSelected = Session()
    var mostRecentBandSelected = Band()
    
    func configurePicCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        if soloPicURLArray.count == 0{
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 2
            cell.deleteButton.isHidden = true
        }else{
            cell.picImageView.image = self.soloPicURLArray[indexPath.row]
            cell.deleteButton.isHidden = true
        }
    }

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
            
            cell.touchBlockingView.isHidden = false
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 0
            
            //cell.youtubePlayerView.isHidden = true
            cell.removeVideoButton.isHidden = true
            cell.noVideosLabel.isHidden = true
            
            
            
            cell.videoURL =  self.bandMedia[indexPath.row] as NSURL?
            if(String(describing: cell.videoURL).contains("youtube") || String(describing: cell.videoURL).contains("youtu.be")){
                print("youtubeSelected")
                cell.youtubePlayerView.loadVideoURL(cell.videoURL as! URL)
                cell.youtubePlayerView.isHidden = false
                cell.player?.view.isHidden = true
                cell.isYoutube = true
            }else{
                print("vidFromPhoneSelected")
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
    @IBAction func soloSessionPressed(_ sender: Any) {
        self.soloPicker.isHidden = false
        self.soloPickerUsed = true
        self.yourBandsCollect.isHidden = true
        self.onbCollect.isHidden = true
        self.sessionCollectionView.isHidden = true
        self.selectVideoFromSessionCollect.isHidden = true
        self.uploadBandToFeed.isHidden = true
        

    }
    @IBAction func bandTypePressed(_ sender: Any) {
        self.soloPicker.isHidden = true
        //self.soloPickerUsed = false
        self.onbCollect.isHidden = true
        self.yourBandsCollect.isHidden = false
        self.bandType = "band"
        self.sessionCollectionView.isHidden = true
        self.selectVideoFromSessionCollect.isHidden = true
        self.uploadBandToFeed.isHidden = false
        yourONBsLabel.isHidden = true
        yourBandsLabel.isHidden = false
       

    }
    @IBAction func oneNightBandTypePressed(_ sender: Any) {
        self.soloPicker.isHidden = true
        //self.soloPickerUsed = false
        self.onbCollect.isHidden = false
        self.yourBandsCollect.isHidden = true
        
        self.bandType = "onb"
        self.sessionCollectionView.isHidden = true
        self.selectVideoFromSessionCollect.isHidden = true
        self.uploadBandToFeed.isHidden = false
        yourONBsLabel.isHidden = false
        yourBandsLabel.isHidden = true
    }
    @IBOutlet weak var yourONBsLabel: UILabel!
    @IBOutlet weak var yourBandsLabel: UILabel!
    func configureCell(_ cell: SessionCell,_ collectionView: UICollectionView, forIndexPath indexPath: NSIndexPath) {
        //print(self.currentCollect)
        if collectionView == self.onbCollect{
            cell.sessionCellImageView.loadImageUsingCacheWithUrlString(onbObjectArray[indexPath.row].onbPictureURL[0])
            cell.sessionCellLabel.text = onbObjectArray[indexPath.row].onbName
            cell.sessionCellLabel.textColor = UIColor.white
            cell.layer.borderWidth = cell.cellSelected ? 2 : 0
            cell.layer.borderColor = cell.cellSelected ? ONBPink.cgColor : UIColor.clear.cgColor
            cell.sessionId = onbArray[indexPath.row]
        }
        if collectionView == self.yourBandsCollect{
            print(bandObjectArray[indexPath.row].bandPictureURL[0])
            //print(bandObjectArray)
            cell.sessionCellImageView.loadImageUsingCacheWithUrlString(bandObjectArray[indexPath.row].bandPictureURL[0])
            cell.sessionCellLabel.text = bandObjectArray[indexPath.row].bandName
            cell.sessionCellLabel.textColor = UIColor.white
            cell.layer.borderWidth = cell.cellSelected ? 2 : 0
            cell.layer.borderColor = cell.cellSelected ? ONBPink.cgColor : UIColor.clear.cgColor
            
            cell.sessionId = bandArray[indexPath.row]

        }
        if collectionView == self.sessionCollectionView{
        cell.sessionCellImageView.loadImageUsingCacheWithUrlString(bandSessionObjectArray[indexPath.row].sessionPictureURL[0])
        cell.sessionCellLabel.text = bandSessionObjectArray[indexPath.row].sessionName
        cell.sessionCellLabel.textColor = UIColor.white
        cell.layer.borderWidth = cell.cellSelected ? 2 : 0
        cell.layer.borderColor = cell.cellSelected ? ONBPink.cgColor : UIColor.clear.cgColor

        cell.sessionId = bandSessionIDArray[indexPath.row]
        }
        if collectionView == self.selectVideoFromSessionCollect{
            cell.sessionCellImageView.loadImageUsingCacheWithUrlString(bandSessionObjectArray[indexPath.row].sessionPictureURL[0])
            cell.sessionCellLabel.text = bandSessionObjectArray[indexPath.row].sessionName
            cell.sessionCellLabel.textColor = UIColor.white
            cell.layer.borderWidth = cell.cellSelected ? 2 : 0
            cell.layer.borderColor = cell.cellSelected ? ONBPink.cgColor : UIColor.clear.cgColor
            
            cell.sessionId = bandSessionIDArray[indexPath.row]
        }
        
        }
    var soloPressed = Bool()

    @IBAction func uploadSoloPressed(_ sender: Any) {
        if (self.selectedSoloVidArray.count != 0 || self.selectedSoloPicArray.count != 0) && self.soloSessTextView.text.isEmpty == false && self.soloSessionNameTextView.text?.isEmpty == false{
            soloPressed = true
            SwiftOverlays.showBlockingTextOverlay("Uploading Session to Feed")
            
            uploadMovieToFirebaseStorage()
            
        }else{
            let alert = UIAlertController(title: "Missing Info", message: "One or more of the required fields is missing.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        

    }
 
    func textViewDidBeginEditing(_ textView: UITextView) {
        if soloSessTextView.textColor == ONBPink {
            soloSessTextView.text = nil
            soloSessTextView.textColor = UIColor.white
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if soloSessTextView.text.isEmpty {
            soloSessTextView.text = "Give a little background on the session you are uploading."
            soloSessTextView.textColor = ONBPink
        }
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
            let storageRef = Storage.storage().reference().child("session_images").child("\(imageName).jpg")
            
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
                        tempArray2.append((Auth.auth().currentUser?.uid)! as String)
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
                        
                        
                        let ref = Database.database().reference()
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
                        let user = Auth.auth().currentUser?.uid
                        //var sessionVals = Dictionary
                        //let userSessRef = ref.child("users").child(user).child("activeSessions")
                        self.ref.child("users").child(user!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
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
        if self.selectedSessionMediaArray.count != 0{
            
           
                SwiftOverlays.showBlockingTextOverlay("Uploading Session to Feed")
                
                uploadMovieToFirebaseStorage()
           // }
        }else{
            let alert = UIAlertController(title: "No Session Selected", message: "Select a session above from either your solo sessions or one of your band's sessions. Upload the entire session or handpick which videos get added to the feed.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    var bandType = String()
    func uploadMovieToFirebaseStorage(){
        if bandType == "solo"{
            let recipient = self.ref.child("sessionFeed")
            let recipient2 = self.ref.child("users")
            var values = Dictionary<String, Any>()
            var values2 = Dictionary<String, Any>()
            
            values["sessionName"] = self.soloSessionNameTextView.text
            values["sessionArtists"] = [userID!: "-"] as [String: Any]
            values["sessionBio"] = self.soloSessTextView.text
            values["sessionDate"] = ""
            values["sessionID"] = ""
            values["bandID"] = self.userID
            values["bandName"] = self.currentUserNameLabel.text
            
            var tempArray = [String]()
            for pic in selectedSoloPicArray{
                tempArray.append(String(describing: pic))
            }
            values["sessionPictureURL"] = tempArray
            values["views"] = 0
            var tempVidArray = [String]()
            for vid in selectedSoloVidArray{
                tempVidArray.append(String(describing: vid))
            }
            
            values["sessionMedia"] = tempVidArray
            values["soloSessBool"] = "true"
            
            
            for url in self.selectedSoloVidArray{
                
                let videoName = NSUUID().uuidString
                let storageRef = Storage.storage().reference(withPath: "session_videos/").child("\(videoName).mov")
                let uploadMetadata = StorageMetadata()
                uploadMetadata.contentType = "video/quicktime"
                let uploadTask = storageRef.putFile(from: url as URL, metadata: uploadMetadata){(metadata, error) in
                    if(error != nil){
                        print("got an error: \(error)")
                    }else{
                        print("upload complete: metadata = \(metadata)")
                        print("download url = \(metadata?.downloadURL())")
                    }
                }
            }
            for pic in selectedSoloPicArray{
                print("soloPic:\(pic)")
                let imageName = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("profile_images/").child("\(imageName).jpg")
                if let uploadData = UIImageJPEGRepresentation(pic, 0.1) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print(error!)
                            return
                        }
                    })
                }
            }
            
            let autoId = recipient.childByAutoId()
            
            values2["soloSessKeysOnFeed"] = [String(describing: autoId)]
            //self.autoIdString = String(describing: autoId)
            print("valuesB4Upload: \(values)")
            autoId.updateChildValues(values, withCompletionBlock: {(err, ref) in
                if err != nil {
                    print(err as Any)
                    return
                }
                
                
            })
            recipient2.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                if err != nil {
                    print(err as Any)
                    return
                }
                DispatchQueue.main.async {
                    print("segue")
                    self.performSegue(withIdentifier: "CancelPressed", sender: self)
                }
            })
        }
        if bandType == "onb"{
    
        }
        if bandType == "band"{
                let recipient = self.ref.child("sessionFeed")
                let recipient2 = self.ref.child("bands").child(self.mostRecentBandSelected.bandID!)
                let recipient3 = self.ref.child("sessions").child(self.mostRecentSessionSelected.sessionUID)
                print("mrss.sessionUID: \(self.mostRecentSessionSelected.sessionUID)")
                var selectedMediaAsString = [String]()
                for url in self.selectedSessionMediaArray{
                    selectedMediaAsString.append(String(describing: url))
                }
        
                        var values = Dictionary<String, Any>()
                        var values2 = Dictionary<String, Any>()
                        var values3 = Dictionary<String, Any>()
                        values["bandID"] = self.mostRecentBandSelected.bandID
            values["bandName"] = self.mostRecentBandSelected.bandName
                        values["sessionName"] = self.mostRecentSessionSelected.sessionName
                        values["sessionArtists"] = self.mostRecentBandSelected.bandMembers
                        values["sessionBio"] = self.mostRecentSessionSelected.sessionBio
                        values["sessionDate"] = self.mostRecentSessionSelected.sessionDate
                        values["sessionID"] = self.mostRecentSessionSelected.sessionUID
            values["soloSessBool"] = "false"
            values["bandType"] = self.bandType
        ///
                        values["sessionPictureURL"] = self.mostRecentSessionSelected.sessionPictureURL
                        values["views"] = 0
        var tempVidArray = [String]()
        for vid in selectedSessionMediaArray{
            tempVidArray.append(String(describing: vid))
        }
        
                        values["sessionMedia"] = tempVidArray
                        
                        var tempSessArray = (self.mostRecentBandSelected.sessionsOnFeed)
                        tempSessArray.append(self.mostRecentSessionSelected.sessionUID)
                        values2["sessionsOnFeed"] = tempSessArray
                        
                        var tempURLArray = self.mostRecentSessionSelected.sessFeedMedia
            if tempURLArray == nil{
                tempURLArray = [String]()
            }
                        for url in self.selectedSessionMediaArray{
                            if tempURLArray?.count != 0{
                            
                                tempURLArray!.append(String(describing: url))
                                
                            } else {
                                tempURLArray!.append(String(describing: url))
                            }
                            let videoName = NSUUID().uuidString
                            let storageRef = Storage.storage().reference(withPath: "session_videos/").child("\(videoName).mov")
                            let uploadMetadata = StorageMetadata()
                            uploadMetadata.contentType = "video/quicktime"
                            let uploadTask = storageRef.putFile(from: url as URL, metadata: uploadMetadata){(metadata, error) in
                                if(error != nil){
                                    print("got an error: \(error)")
                                }else{
                                    print("upload complete: metadata = \(metadata)")
                                    print("download url = \(metadata?.downloadURL())")
                                }
                            }

        }
                        values3["sessFeedMedia"] = tempURLArray
                        
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
                        })
                        recipient3.updateChildValues(values3, withCompletionBlock: {(err, ref) in
                            if err != nil {
                                print(err)
                                return
                            }
                            self.performSegue(withIdentifier: "CancelPressed", sender: self)
                        })
        /*uploadTask.observe(.progress){[weak self] (snapshot) in
            guard let strongSelf = self else {return}
            guard let progress = snapshot.progress else {return}
            strongSelf.progressView.progress = Float(progress.fractionCompleted)
            print("Uploaded \(progress.completedUnitCount) so far")
        }*/
        }
       
            
    }
    var movieURLFromPicker: NSURL?


}

/*extension UploadSessionPopup: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
}*/



