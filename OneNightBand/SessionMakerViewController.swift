//
//  SessionMakerViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/8/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
//import Firebase
import FirebaseStorage
import FirebaseDatabase
//import Firebase
import UIKit
import FirebaseAuth




protocol GetSessionIDDelegate : class
{
    func getSessID()->String
    
}
protocol SessionIDDest : class
{
    weak var getSessionID : GetSessionIDDelegate? { get set }
}





class SessionMakerViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, GetSessionIDDelegate, DismissalDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var tabBar: UITabBar!
    internal func finishedShowing() {
        
    }

    
    var sessionID: String?
    
    
    @IBAction func addSessionTouched(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateSessionPopup") as! CreateSessionPopup
        popOverVC.bandID = self.thisBand.bandID
        popOverVC.bandObject = self.thisBand
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        
    }
    
    
    @IBOutlet weak var addNewSession: UIButton!
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var addSessionPicButton: UIButton!
    @IBOutlet weak var AddMusiciansButton: UIButton!
    @IBOutlet weak var sessionArtistsTableView: UITableView!
    @IBOutlet weak var sessionInfoTextView: UITextView!
    @IBOutlet weak var editSessionInfoButton: UIButton!
    @IBOutlet weak var removeArtistButton: UIButton!
    
    @IBOutlet weak var becomeFanButton: UIButton!
    @IBAction func becomeFanPressed(_ sender: Any) {
    }
    @IBOutlet weak var editSessionButton: UIButton!
    var cellTouchedArtistUID = String()
    var sender = String()
    @IBOutlet weak var uploadSessionToFeed: UIButton!
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "SessionToArtistFinder"{
            if let vc = segue.destination as? ArtistFinderViewController
            {
                vc.bandID = sessionID!
                vc.thisBandObject = thisBand
                vc.bandType = "band"
                
            }
        }
        if segue.identifier == "SessionToChat"{
            if let vc = segue.destination as? ChatViewController{
                let userID = FIRAuth.auth()?.currentUser?.uid
                vc.thisSessionID = getSessID()
                vc.senderId = userID
                vc.senderDisplayName = userID
            }
        }
        if segue.identifier == "ArtistCellTouched"{
            if let vc = segue.destination as? ArtistProfileViewController{
                vc.artistUID = cellTouchedArtistUID
            }
        }
        if segue.identifier == "SessionToMP3"{
            if let vc = segue.destination as? MP3PlayerViewController{
                vc.BandID = self.sessionID!
                print("sesssssss: \(self.sessionID!)")
                print(self.selectedCell?.sessionId)
                vc.sessionID = self.selectedCell?.sessionId
                vc.navigationController?.isNavigationBarHidden = false
                vc.navigationItem.hidesBackButton = false
                if self.sender != "feed" {
                    vc.sender = "bandPage"
                } else {
                    vc.sender = "feed"
                }
                
            }

        }
        
    }
    
    var yearsArray = [String]()
    var playingYearsArray = ["1","2","3","4","5+","10+"]
    var playingLevelArray = ["beginner", "intermediate", "advanced", "expert"]

    @IBAction func chatPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "SessionToChat", sender: self)
    }
    @IBOutlet weak var chatViewContainerView: UIView!
    
    @IBAction func addMusicianPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "SessionToArtistFinder", sender: self)
    }
    var ref = FIRDatabase.database().reference()
    var sessionIDArray = [String]()
    var thisBand = Band()
    var sessionChat = ChatViewController()
    var sizingCell2: VideoCollectionViewCell?
    
    @IBOutlet weak var sessionVidCollectionView: UICollectionView!
    
    @IBOutlet weak var chatButton: UIButton!
    
    func getSessID()->String{
        return sessionID!
    }
    
    @IBAction func ourSessionsPressed(_ sender: Any) {
    }
    @IBOutlet weak var ourSessionsButton: UIButton!
    var mediaKidArray = [String]()
    
    @IBOutlet weak var allSessionsCollect: UICollectionView!
    
    @IBOutlet weak var currentSessionsCollect: UICollectionView!
    
    @IBOutlet weak var fanCount: UILabel!
    @IBOutlet weak var sessionsOnFeedCollect: UICollectionView!
    @IBOutlet weak var upcomingSessionsCollect: UICollectionView!
    @IBOutlet weak var pastSessionsCollect: UICollectionView!
    var vidArray = [NSURL]()
    
    var sizingCell: SessionCell?
    override func viewDidLoad(){
        
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        
        sessionPicker.delegate = self
        sessionPicker.dataSource = self
        //sessionPicker.selectRow(1, inComponent: 1, animated: false)
        
        loadCollectionViews()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        DispatchQueue.main.async{
            self.allSessionsCollect.isHidden = false
        }
        /*editSessionButton.setTitle("Add and Remove Media", for: .normal)
        editSessionButton.titleLabel?.numberOfLines = 3
        editSessionButton.setTitleColor(UIColor.darkGray, for: .normal)
        editSessionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightLight)
        editSessionButton.titleLabel?.textAlignment = NSTextAlignment.center*/
        
        //AddMusiciansButton.setTitle("Find Musicians", for: .normal)
        //AddMusiciansButton.titleLabel?.numberOfLines = 2
        //AddMusiciansButton.setTitleColor(UIColor.darkGray, for: .normal)
       // AddMusiciansButton.titleLabel?.font = UIFont.systemFont(ofSize: 23.0, weight: UIFontWeightLight)
        if self.sender != "feed" || self.sender == "bandBoard" || self.sender == "pfm"{
            self.becomeFanButton.isHidden = true
            AddMusiciansButton.titleLabel?.textAlignment = NSTextAlignment.center
            editSessionInfoButton.isHidden = false
        
            chatButton.setTitle("Band Chat", for: .normal)
            chatButton.titleLabel?.numberOfLines = 2
            chatButton.setTitleColor(UIColor.white, for: .normal)
            chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightLight)
            chatButton.titleLabel?.textAlignment = NSTextAlignment.center
        
            addNewSession.setTitle("New Session", for: .normal)
            addNewSession.titleLabel?.numberOfLines = 2
            addNewSession.setTitleColor(UIColor.white, for: .normal)
            addNewSession.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightLight)
            addNewSession.titleLabel?.textAlignment = NSTextAlignment.center
        } else {
            
            editSessionInfoButton.isHidden = true
            AddMusiciansButton.isHidden = true
            chatButton.isHidden = true
            addNewSession.isHidden = true
            self.becomeFanButton.isHidden = false
        }
        
        

        
        
        
        ref.child("users").child(userID!).child("artistsBands").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    self.sessionIDArray.append((snap.value! as! String))
                }
            }
        print(self.getSessID())
        self.ref.child("bands").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if (snap.key == self.getSessID()){
                            
                            let dictionary = snap.value as? [String: AnyObject]
                            print(dictionary)
                            let tempBand = Band()
                            tempBand.setValuesForKeys(dictionary!)
                            self.thisBand = tempBand
                            
                            for val in tempBand.bandMedia{
                                //self.mediaKidArray.append(val)
                                self.vidArray.append(NSURL(string: val)!)
                            }
                            self.sessionID = self.thisBand.bandID
                            self.sessionInfoTextView?.text = tempBand.bandBio!
                            self.sessionImageView?.loadImageUsingCacheWithUrlString(tempBand.bandPictureURL[0])
                            self.navigationItem.title = tempBand.bandName
                            //print(self.thisSession.sessionBio)
                            let cellNib = UINib(nibName: "ArtistCell", bundle: nil)
                            self.sessionArtistsTableView.register(cellNib, forCellReuseIdentifier: "ArtistCell")
                            self.sessionArtistsTableView.delegate = self
                            self.sessionArtistsTableView.dataSource = self
                            break
                        }
                }
                   /* for _ in self.vidArray{
                        
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.sessionVidCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.sessionVidCollectionView.backgroundColor = UIColor.clear
                        self.sessionVidCollectionView.delegate = self
                        self.sessionVidCollectionView.dataSource = self
                        self.sessionChat.thisSessionID = self.getSessID()
                        //self.view.setNeedsDisplay()
                        
                    }*/


            }
            DispatchQueue.main.async{
                self.sessionArtistsTableView.reloadData()
                //self.sessionVidCollectionView.reloadData()
                print("vidArray: \(self.vidArray)")
                if self.sender == "pfm"{
                    self.performSegue(withIdentifier: "SessionToArtistFinder", sender: self)
                }
                
            }

            
            
        
        })
    
    
    })
        
        
}
    
    
    var allSessionsDict = [String: Session]()
    var pastSessionArray = [Session]()
    var upcomingSessionArray = [Session]()
    var activeSessionsArray = [Session]()
    var sessionFeedArray = [Session]()
    var allSessions = [Session]()
    var bandSessions = [String]()
    
    var curFeedArrayIndex = 0
    var curPastArrayIndex = 0
    var curActiveArrayIndex = 0
    var curUpcomingArrayIndex = 0
    
    func loadCollectionViews(){
        activeSessionsArray.removeAll()
        pastSessionArray.removeAll()
        upcomingSessionArray.removeAll()
        sessionFeedArray.removeAll()
        sessionIDArray.removeAll()
        allSessions.removeAll()
        bandSessions.removeAll()
        navigationItem.title = "Our Sessions"
        allSessionsCollect.isHidden = true
        upcomingSessionsCollect.isHidden = true
        pastSessionsCollect.isHidden = true
        currentSessionsCollect.isHidden = true
        sessionsOnFeedCollect.isHidden = true
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        self.ref.child("sessions").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshotsss = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshotsss{
                    let dictionary = snap.value as? [String: Any]
                    print("dict: \(dictionary)")
                    let tempSess = Session()
                    tempSess.setValuesForKeys(dictionary!)
                    self.allSessionsDict[tempSess.sessionUID] = tempSess
                }
            }
            
            self.ref.child("bands").child(self.sessionID!).child("bandSessions").observeSingleEvent(of: .value, with: { (ssnapshot) in
                if let ssnapshots = ssnapshot.children.allObjects as? [FIRDataSnapshot]{
                    for ssnap in ssnapshots{
                        self.bandSessions.append((ssnap.value! as! String))
                    }
                }
                self.bandSessions.reverse()
                
                self.ref.child("sessionFeed").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            let sessionKids = snap.children.allObjects as? [FIRDataSnapshot]
                            for ssnap in sessionKids!{
                                if ssnap.key == "sessionUID"{
                                    
                                    let dictionary = snap.value as? [String: Any]
                                    let tempSess = Session()
                                    tempSess.setValuesForKeys(dictionary!)
                                    if self.sessionIDArray.contains(tempSess.sessionUID) {
                                        
                                        self.sessionFeedArray.append(self.allSessionsDict[tempSess.sessionUID]!)
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    print("sessIDArray: \(self.bandSessions)")
                    self.ref.child("sessions").observeSingleEvent(of: .value, with: {(snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            
                            for snap in snapshots{
                                print("snapKey: \(snap.key)")
                                for id in self.bandSessions{
                                    if snap.key == id{
                                        print("id: \(id)")
                                        let dictionary = snap.value as? [String: Any]
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.timeStyle = DateFormatter.Style.none
                                        dateFormatter.dateStyle = DateFormatter.Style.short
                                        let now = Date()
                                        let order = Calendar.current.compare(now, to: self.dateFormatted(dateString: dictionary?["sessionDate"] as! String), toGranularity: .day)
                                        //print(now)
                                        //print(self.dateFormatted(dateString: dictionary?["sessionDate"] as! String))
                                        let tempSess2 = Session()
                                        tempSess2.setValuesForKeys(dictionary!)
                                        
                                        self.allSessions.append(tempSess2)
                                        
                                        switch order {
                                            
                                        case .orderedSame:
                                            let tempSess = Session()
                                            tempSess.setValuesForKeys(dictionary!)
                                            self.activeSessionsArray.append(tempSess)
                                        case .orderedAscending:
                                            let tempSess = Session()
                                            tempSess.setValuesForKeys(dictionary!)
                                            self.upcomingSessionArray.append(tempSess)
                                        case .orderedDescending:
                                            let tempSess = Session()
                                            tempSess.setValuesForKeys(dictionary!)
                                            self.pastSessionArray.append(tempSess)
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        
                        DispatchQueue.main.async {
                            if self.activeSessionsArray.count == 0{
                                self.currentButton = "active"
                                //self.curActiveArrayIndex = self.activeSessionsArray.index(of: session)!
                                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                self.currentSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                //self.currentSessionsCollect.backgroundColor = UIColor.clear
                                self.currentSessionsCollect.dataSource = self
                                self.currentSessionsCollect.delegate = self
                                
                            }else{

                            for session in self.activeSessionsArray{
                                self.currentButton = "active"
                                self.curActiveArrayIndex = self.activeSessionsArray.index(of: session)!
                                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                self.currentSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                //self.currentSessionsCollect.backgroundColor = UIColor.clear
                                self.currentSessionsCollect.dataSource = self
                                self.currentSessionsCollect.delegate = self
                            }
                            }
                            
                            DispatchQueue.main.async {
                                if self.pastSessionArray.count == 0{
                                    self.currentButton = "past"
                                    //self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                                    
                                    let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                    self.pastSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                    self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                    //self.pastSessionsCollect.backgroundColor = UIColor.clear
                                    self.pastSessionsCollect.dataSource = self
                                    self.pastSessionsCollect.delegate = self
                                    
                                }
                                else{

                                for session in self.pastSessionArray{
                                    self.currentButton = "past"
                                    self.curPastArrayIndex = self.pastSessionArray.index(of: session)!
                                    
                                    let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                    self.pastSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                    self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                    //self.pastSessionsCollect.backgroundColor = UIColor.clear
                                    self.pastSessionsCollect.dataSource = self
                                    self.pastSessionsCollect.delegate = self
                                }
                                }
                                
                                
                                DispatchQueue.main.async {
                                    if self.upcomingSessionArray.count == 0{
                                        self.currentButton = "upcoming"
                                        //self.curUpcomingArrayIndex = self.upcomingSessionArray.index(of: session)!
                                        let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                        self.upcomingSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                        // self.upcomingSessionsCollect.backgroundColor = UIColor.clear
                                        self.upcomingSessionsCollect.dataSource = self
                                        self.upcomingSessionsCollect.delegate = self
                                    }
                                    else{

                                    for session in self.upcomingSessionArray{
                                        self.currentButton = "upcoming"
                                        self.curUpcomingArrayIndex = self.upcomingSessionArray.index(of: session)!
                                        let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                        self.upcomingSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                       // self.upcomingSessionsCollect.backgroundColor = UIColor.clear
                                        self.upcomingSessionsCollect.dataSource = self
                                        self.upcomingSessionsCollect.delegate = self
                                    }
                                    }
                                    DispatchQueue.main.async{
                                        if self.allSessions.count == 0{
                                            self.currentButton = "all"
                                            //self.curActiveArrayIndex = self.activeSessionsArray.index(of: session)!
                                            let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                            self.allSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                            self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                            // self.allSessionsCollect.backgroundColor = UIColor.clear
                                            self.allSessionsCollect.dataSource = self
                                            self.allSessionsCollect.delegate = self
                                            
                                        }
                                        else{

                                                                            
                                        for _ in self.allSessions{
                                            self.currentButton = "all"
                                            //self.curAllArrayIndex = self.allSessions.index(of: session)!
                                            
                                            let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                            self.allSessionsCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                            self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                         //   self.allSessionsCollect.backgroundColor = UIColor.clear
                                            self.allSessionsCollect.dataSource = self
                                            self.allSessionsCollect.delegate = self
                                        }
                                        }
                                        
                                    }
                                }
                            }
                            
                        }
 
                        print(self.sessionFeedArray)
                        if self.sessionFeedArray.count == 0{
                            self.currentButton = "feed"
                            //self.curFeedArrayIndex = self.sessionFeedArray.index(of: session)!
                            let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                            self.sessionsOnFeedCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                            self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                            
                            //self.sessionsOnFeedCollect.backgroundColor = UIColor.clear
                            self.sessionsOnFeedCollect.dataSource = self
                            self.sessionsOnFeedCollect.delegate = self
                            
                        }else{

                        for session in self.sessionFeedArray{
                            if self.sessionIDArray.contains(session.sessionUID){
                                self.currentButton = "feed"
                                self.curFeedArrayIndex = self.sessionFeedArray.index(of: session)!
                                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                                self.sessionsOnFeedCollect.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                                
                                //self.sessionsOnFeedCollect.backgroundColor = UIColor.clear
                                self.sessionsOnFeedCollect.dataSource = self
                                self.sessionsOnFeedCollect.delegate = self
                            }
                            }
                                                    }
                        
                        
                    })
                    
                    
                })
                
            })
            
        })
    }

    
    
    var currentButton = String()
    
    //var vidCellBool: Bool?
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        return (self.thisBand.bandMembers.count)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //(tableView.cellForRow(at: indexPath) as ArtistCell).artistUID
        self.cellTouchedArtistUID = (tableView.cellForRow(at: indexPath) as! ArtistCell).artistUID
        performSegue(withIdentifier: "ArtistCellTouched", sender: self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print(currentButton as Any)
        if(self.currentButton == "upcoming"){
            if upcomingSessionArray.count == 0{
                return 1
            }else{
                return upcomingSessionArray.count
            }
            
            
        }
        else if(self.currentButton == "past"){
            if pastSessionArray.count == 0{
                return 1
            }else{
                return pastSessionArray.count
            }
            
        }
        else if(self.currentButton == "feed"){
            if sessionFeedArray.count == 0{
                return 1
            }else{
                return sessionFeedArray.count
            }
        }
        else if(self.currentButton == "active"){
            if activeSessionsArray.count == 0{
                return 1
            }else{
                return activeSessionsArray.count
            }
        }else if(self.currentButton == "all"){
            if allSessions.count == 0{
                return 1
            }else{
            return allSessions.count
            }
        }
        else{
            return 0
        }
        
    }
    var tempIndex: Int?
    var pressedButton: String?

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath as IndexPath) as! SessionCell
        
        tempIndex = indexPath.row
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    
    var selectedCell: SessionCell?
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // self.bandTypeView.isHidden = true
        /*let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MP3PlayerVC") as! MP3PlayerViewController
        popOverVC.sessionID = (collectionView.cellForItem(at: indexPath) as! SessionCell).sessionId
        //popOverVC.sessionNameLabel.text = (collectionView.cellForItem(at: indexPath) as! SessionCell).sessionCellLabel.text
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)*/
        self.selectedCell = collectionView.cellForItem(at: indexPath) as! SessionCell
        print("selectedCellName: \(self.selectedCell?.sessionCellLabel.text)")
        print("selectedCellID: \(self.selectedCell?.sessionId)")
        self.performSegue(withIdentifier: "SessionToMP3", sender: self)
        //self.dropDownDone = true
        //self.createNewBandButton.isHidden = false

        /*if(collectionView == self.upcomingSessionsCollect){
            tempIndex = indexPath.row
            self.pressedButton = "upcoming"
            performSegue(withIdentifier: "SessionCollectionToSessionView", sender: self)
        }
        if(collectionView == self.pastSessionsCollect){
            tempIndex = indexPath.row
            self.pressedButton = "past"
            performSegue(withIdentifier: "SessionCollectionToSessionView", sender: self)
        }
        if(collectionView == self.sessionsOnFeedCollect){
            tempIndex = indexPath.row
            self.pressedButton = "feed"
            performSegue(withIdentifier: "SessionCollectionToSessionView", sender: self)
        }
        if(collectionView == self.currentSessionsCollect){
            tempIndex = indexPath.row
            self.pressedButton = "active"
            performSegue(withIdentifier: "SessionCollectionToSessionView", sender: self)
        }
        if (collectionView == self.allSessionsCollect){
            tempIndex = indexPath.row
            self.pressedButton = "all"
            performSegue(withIdentifier: "SessionCollectionToSessionView", sender: self)
        }*/
        
    }
    var cellArray = [SessionCell]()
    func configureCell(_ cell: SessionCell, forIndexPath indexPath: NSIndexPath) {
        
        if(self.currentButton == "upcoming"){
            print("Whyyyyy")
            if upcomingSessionArray.count == 0{
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Upcoming Sessions"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
            }
            
            if(indexPath.row < upcomingSessionArray.count){
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((upcomingSessionArray[indexPath.row] as Session).sessionPictureURL[0])
                //print(self.upcomingSessionArray[indexPath.row].sessionUID as Any)
                cell.sessionCellLabel.text = upcomingSessionArray[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
            
        }
        if(self.currentButton == "past"){
            if pastSessionArray.count == 0{
                cell.isHidden = false
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Past Sessions"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false
                if(indexPath.row < pastSessionArray.count){
                    
                    cell.sessionCellImageView.loadImageUsingCacheWithUrlString((pastSessionArray[indexPath.row] as Session).sessionPictureURL[0])
                    cell.sessionCellLabel.text = pastSessionArray[indexPath.row].sessionName
                    cell.sessionCellLabel.textColor = UIColor.white
                    cell.sessionId = bandSessions[indexPath.row]
                }

            }
                        cellArray.append(cell)
        }
        if(self.currentButton == "feed"){
            if sessionFeedArray.count == 0{
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Sessions On Feed"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false

            }
            
            if(indexPath.row < sessionFeedArray.count){
                print(indexPath.row)
                                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((sessionFeedArray[indexPath.row] as Session).sessionPictureURL[0])
                cell.sessionCellLabel.text = sessionFeedArray[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
        }
        if(self.currentButton == "active"){
            if activeSessionsArray.count == 0{
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Active Sessions"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
                
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false
            }
            if(indexPath.row < activeSessionsArray.count){
                
                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((activeSessionsArray[indexPath.row] as Session).sessionPictureURL[0])
                cell.sessionCellLabel.text = activeSessionsArray[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
        }
        if(self.currentButton == "all"){
            if allSessions.count == 0{
                cell.sessionCellImageView.isHidden = true
                cell.sessionCellLabel.isHidden = true
                cell.emptyLabel.isHidden = false
                cell.emptyLabel.text = "No Sessions to Show"
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.emptyLabel.textColor = UIColor.white
            }else{
                cell.emptyLabel.isHidden = true
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.sessionCellImageView.isHidden = false
                cell.sessionCellLabel.isHidden = false
            }
            if(indexPath.row < allSessions.count){
                cell.sessionCellImageView.loadImageUsingCacheWithUrlString((allSessions[indexPath.row] as Session).sessionPictureURL[0])
                cell.sessionCellLabel.text = allSessions[indexPath.row].sessionName
                cell.sessionCellLabel.textColor = UIColor.white
                cell.sessionId = bandSessions[indexPath.row]
            }
            cellArray.append(cell)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        /*if(self.currentButton == "active"){
            
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.activeSessionsArray.count)
                let totalSpacingWidth = 10 * (self.activeSessionsArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
        
        else if(self.currentButton == "past"){
            
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.pastSessionArray.count)
                let totalSpacingWidth = 10 * (self.pastSessionArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
        
        else if(self.currentButton == "upcoming"){
            
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.upcomingSessionArray.count)
                let totalSpacingWidth = 10 * (self.upcomingSessionArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
        
        else if(self.currentButton == "all"){
            
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.allSessions.count)
                let totalSpacingWidth = 10 * (self.allSessions.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }
        
        else{
            
                
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.sessionFeedArray.count)
                let totalSpacingWidth = 10 * (self.sessionFeedArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            
        }*/
        return UIEdgeInsetsMake(0, 0, 0, 0)
        
    }
    
    
    func finishedShowing(viewController: UIViewController) {
        //if viewController.isBeingPresented && viewController.presentingViewController == self
        //{
        //self.shadeView.isHidden = true
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
        /*self.allSessionsCollect.reloadData()
        self.currentSessionsCollect.reloadData()
        self.pastSessionsCollect.reloadData()
        self.upcomingSessionsCollect.reloadData()
        self.sessionsOnFeedCollect.reloadData()
        self.dismiss(animated: true, completion: nil)*/
        return
        //}
        
        // self.navigationController?.popViewController(animated: true)
    }

    
    
    
    
    

    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath as IndexPath) as! ArtistCell
        let tempArtist = Artist()
        //let userID = FIRAuth.auth()?.currentUser?.uid
        var artistArray = [String]()
        var instrumentArray = [String]()
        for value in thisBand.bandMembers{
            artistArray.append(value.key)
            instrumentArray.append(value.value as! String)
        }
        

        ref.child("users").child(artistArray[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
        
        
            let dictionary = snapshot.value as? [String: AnyObject]
            tempArtist.setValuesForKeys(dictionary!)

            /*var tempInstrument = ""
            let userID = FIRAuth.auth()?.currentUser?.uid
            for value in self.thisSession.sessionArtists{
                if value.key == userID{
                    tempInstrument = value.value as! String
                    
                }
            }*/
            cell.artistUID = tempArtist.artistUID!
            
            print(instrumentArray)
            cell.artistNameLabel.text = tempArtist.name
            cell.artistInstrumentLabel.text = "test"
            cell.artistImageView.loadImageUsingCacheWithUrlString(tempArtist.profileImageUrl.first!)
            cell.artistInstrumentLabel.text = instrumentArray[indexPath.row]
        
            })
        return cell
    }
    
    func dateFormatted(dateString: String)->Date{
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM-dd-yy"
        
        let dateObj = dateFormatter.date(from: dateString)
        
        
        return(dateObj)!
        
    }
    
    @IBOutlet weak var sessionPicker: UIPickerView!
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    // returns the # of rows in each component..
    var sessText = ["All","Upcoming","Past", "Active","On Feed"]
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return sessText.count
        
    }
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let titleData = sessText[row]
        
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 8.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if self.sessText[row] == "Past"{
            print("p")
            /*if pastSessionArray.count == 0{
                (pastSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = false
                (pastSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.text = "No Past Sessions"
                (pastSessionsCollect.visibleCells.first as! SessionCell).layer.borderColor = UIColor.white.cgColor
                (pastSessionsCollect.visibleCells.first as! SessionCell).layer.borderWidth = 2
                (pastSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.textColor = UIColor.white
            }else{
                (pastSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = true
            }*/
            print(pastSessionArray.count)
            currentSessionsCollect.isHidden = true
            upcomingSessionsCollect.isHidden = true
            pastSessionsCollect.isHidden = false
            sessionsOnFeedCollect.isHidden = true
            allSessionsCollect.isHidden = true
        }else if self.sessText[row] == "Active"{
           /* if activeSessionsArray.count == 0{
                (currentSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = false
                (currentSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.text = "No Active Sessions"
                (currentSessionsCollect.visibleCells.first as! SessionCell).layer.borderColor = UIColor.white.cgColor
                (currentSessionsCollect.visibleCells.first as! SessionCell).layer.borderWidth = 2
                (currentSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.textColor = UIColor.white
            }else{
                (currentSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = true
            }*/

            
            print("a")
            print(activeSessionsArray.count)
            currentSessionsCollect.isHidden = false
            upcomingSessionsCollect.isHidden = true
            pastSessionsCollect.isHidden = true
            sessionsOnFeedCollect.isHidden = true
            allSessionsCollect.isHidden = true
        }else if self.sessText[row] == "Upcoming"{
           /* if upcomingSessionArray.count == 0{
                (upcomingSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = false
                (upcomingSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.text = "No Upcoming Sessions"
                (upcomingSessionsCollect.visibleCells.first as! SessionCell).layer.borderColor = UIColor.white.cgColor
                (upcomingSessionsCollect.visibleCells.first as! SessionCell).layer.borderWidth = 2
                (upcomingSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.textColor = UIColor.white
            }else{
                (upcomingSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = true
            }*/

            print("U")
            print(upcomingSessionArray.count)
            currentSessionsCollect.isHidden = true
            upcomingSessionsCollect.isHidden = false
            pastSessionsCollect.isHidden = true
            sessionsOnFeedCollect.isHidden = true
            allSessionsCollect.isHidden = true
        }
        else if self.sessText[row] == "All"{
           /* if allSessions.count == 0{
                (allSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = false
                (allSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.text = "No Sessions to Display"
                (allSessionsCollect.visibleCells.first as! SessionCell).layer.borderColor = UIColor.white.cgColor
                (allSessionsCollect.visibleCells.first as! SessionCell).layer.borderWidth = 2
                (allSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.textColor = UIColor.white
            }else{
                (allSessionsCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = true
            }*/

            
            print("all")
            print(allSessions.count)
            currentSessionsCollect.isHidden = true
            upcomingSessionsCollect.isHidden = true
            pastSessionsCollect.isHidden = true
            sessionsOnFeedCollect.isHidden = true
            allSessionsCollect.isHidden = false
            
        }
        else{
            
            /*if sessionFeedArray.count == 0{
                (sessionsOnFeedCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = false
                (sessionsOnFeedCollect.visibleCells.first as! SessionCell).emptyLabel.text = "No Sessions On Feed"
                (sessionsOnFeedCollect.visibleCells.first as! SessionCell).layer.borderColor = UIColor.white.cgColor
                (sessionsOnFeedCollect.visibleCells.first as! SessionCell).layer.borderWidth = 2
                (sessionsOnFeedCollect.visibleCells.first as! SessionCell).emptyLabel.textColor = UIColor.white
            }else{
                (sessionsOnFeedCollect.visibleCells.first as! SessionCell).emptyLabel.isHidden = true
            }*/

            
            print("f")
            print(sessionFeedArray.count)
            currentSessionsCollect.isHidden = true
            upcomingSessionsCollect.isHidden = true
            pastSessionsCollect.isHidden = true
            sessionsOnFeedCollect.isHidden = false
            allSessionsCollect.isHidden = true
            
            
        }
        
        
    }



    
    

}
