//
//  profileRedesignViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 5/22/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class profileRedesignViewController: UIViewController, UITabBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var picArray = [UIImage]()
    let userID = FIRAuth.auth()?.currentUser?.uid
    var yearsArray = [String]()
    var playingYearsArray = ["1","2","3","4","5+","10+"]
    var playingLevelArray = ["beginner", "intermediate", "advanced", "expert"]
    var tempLink: NSURL?
    var rotateCount = 0
    var sizingCell: PictureCollectionViewCell?
    var sizingCell2: VideoCollectionViewCell?
    var sizingCell3: VideoCollectionViewCell?
    var sizingCell4: SessionCell?
    var instrumentArray = [String]()
    var youtubeArray = [NSURL]()
    var nsurlArray = [NSURL]()
    var ref = FIRDatabase.database().reference()
    var dictionaryOfInstruments = [String: Any]()
    var tags = [Tag]()
    var vidFromPhoneArray = [NSURL]()
    var viewDidAppearBool = false
    var isYoutubeCell: Bool?
    var skillArray = [String]()
    var currentCollect = String()
    var nsurlDict = [NSURL: String]()

    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var artistBio: UITextView!
    @IBOutlet weak var onbCollect: UICollectionView!
    @IBOutlet weak var bandCollect: UICollectionView!
    @IBOutlet weak var instrumentTableView: UITableView!
    @IBOutlet weak var videoCollectionView: UICollectionView!

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var infoShiftLocation: UIView!
    @IBAction func bandCountPressed(_ sender: Any) {
        if infoExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoViewBounds
                self.artistInfoView.frame.origin = self.infoViewOrigin
                self.onbCollect.isHidden = false
                self.bandCollect.isHidden = true
                self.instrumentTableView.isHidden = true
                self.videoCollectionView.isHidden = true
                //self.positionView.isHidden = true
                
            })
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoShiftViewBounds
                self.artistInfoView.frame.origin = self.infoShiftViewOrigin
                //self.positionView.isHidden = true
                
            })
            
        }
        infoExpanded = !self.infoExpanded
        

    }
    @IBAction func mediaButtonPressed(_ sender: Any) {
        if infoExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoViewBounds
                self.artistInfoView.frame.origin = self.infoViewOrigin
                //self.positionView.isHidden = true
                
            })
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoShiftViewBounds
                self.artistInfoView.frame.origin = self.infoShiftViewOrigin
                //self.positionView.isHidden = true
                
            })
            
        }
        infoExpanded = !self.infoExpanded
    }
    @IBAction func instrumentButtonTouched(_ sender: Any) {
        if infoExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoViewBounds
                self.artistInfoView.frame.origin = self.infoViewOrigin
                //self.positionView.isHidden = true
                
            })
            
        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.artistInfoView.bounds = self.infoShiftViewBounds
                self.artistInfoView.frame.origin = self.infoShiftViewOrigin
                //self.positionView.isHidden = true
                
            })
            
        }
        infoExpanded = !self.infoExpanded
    }
    
    @IBOutlet weak var menuShiftLocation: UIView!
    var menuExpanded = false
    var infoExpanded = false
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var artistInfoView: UIView!
    var menuViewBounds = CGRect()
    var menuViewOrigin = CGPoint()
    var shiftViewBounds = CGRect()
    var shiftViewOrigin = CGPoint()
    
    var infoViewBounds = CGRect()
    var infoViewOrigin = CGPoint()
    var infoShiftViewBounds = CGRect()
    var infoShiftViewOrigin = CGPoint()

    @IBOutlet weak var artistAllInfoView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.delegate = self
        //ONBLabel.isHidden = false
        //artistAllInfoView.isHidden = true
        //rotateView(targetView: backgroundImageView)
        
        menuView.layer.cornerRadius = 10
        //profileImageView.dropShadow()
       
        self.shiftViewBounds = menuShiftLocation.bounds
        
        self.shiftViewOrigin = menuShiftLocation.frame.origin
        self.menuViewBounds = menuView.bounds
        self.menuViewOrigin = menuView.frame.origin
        
        self.infoShiftViewBounds = infoShiftLocation.bounds
        
        self.infoShiftViewOrigin = infoShiftLocation.frame.origin
        self.infoViewBounds = artistInfoView.bounds
        self.infoViewOrigin = artistInfoView.frame.origin
        

        
        menuButton.dropShadow2()
        menuButton.layer.cornerRadius = 10
        artistInfoView.dropShadow3()
        artistInfoView.layer.cornerRadius = 10
        
        self.ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                //fill datasources for collectionViews
                for snap in snapshots{
                    if snap.key == "media"{
                        let mediaSnaps = snap.value as! [String]
                        for m_snap in mediaSnaps{
                            //fill youtubeArray
                            self.youtubeArray.append(NSURL(string: m_snap)!)
                            self.nsurlArray.append(NSURL(string: m_snap)!)
                            if m_snap.contains("yout"){
                                self.nsurlDict[NSURL(string: m_snap)!] = "y"
                            } else {
                                self.nsurlDict[NSURL(string: m_snap)!] = "v"
                            }
                            
                            
                            
                            
                        }
                        
                        
                        //fill prof pic array
                    } else if snap.key == "profileImageUrl"{
                        if let snapshots = snap.children.allObjects as? [FIRDataSnapshot]{
                            for p_snap in snapshots{
                                if let url = NSURL(string: p_snap.value as! String){
                                    if let data = NSData(contentsOf: url as URL){
                                        self.picArray.append(UIImage(data: data as Data)!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            print(self.nsurlArray)
            if self.nsurlArray.count == 0{
                self.currentCollect = "youtube"
                
                self.tempLink = nil
                
                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                //self.youtubeCollectionView.backgroundColor = UIColor.clear
                self.videoCollectionView.dataSource = self
                self.videoCollectionView.delegate = self
                
            }
            for vid in self.nsurlArray{
                
                // Put your code which should be executed with a delay here
                self.currentCollect = "youtube"
                
                self.tempLink = vid
                
                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                //self.youtubeCollectionView.backgroundColor = UIColor.clear
                self.videoCollectionView.dataSource = self
                self.videoCollectionView.delegate = self
            }
            
            
            self.viewDidAppearBool = true
            
            self.ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                self.artistBio.text = value?["bio"] as! String
                self.artistName.text = (value?["name"] as! String)
                let instrumentDict = value?["instruments"] as! [String: Any]
                self.dictionaryOfInstruments = value?["instruments"] as! [String: Any]
                //var instrumentArray = [String]()
                for (key, value) in instrumentDict{
                    self.instrumentArray.append(key)
                    self.skillArray.append(self.playingLevelArray[(value as! [Int])[0]])
                    self.yearsArray.append(self.playingYearsArray[(value as! [Int])[1]])
                    
                }
                
                //print(instrumentArray)
                for _ in self.instrumentArray{
                    let cellNib = UINib(nibName: "InstrumentTableViewCell", bundle: nil)
                    self.instrumentTableView.register(cellNib, forCellReuseIdentifier: "InstrumentCell")
                    self.instrumentTableView.delegate = self
                    self.instrumentTableView.dataSource = self
                }
                
                self.ref.child("users").child(self.userID!).child("activeSessions").observeSingleEvent(of: .value, with: {(snapshot) in
                    /*if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                     
                     
                     }*/
                    for _ in self.picArray{
                        self.currentCollect = "pic"
                        //self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        
                        let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                        self.picCollect.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                        self.picCollect.backgroundColor = UIColor.clear
                        self.picCollect.dataSource = self
                        self.picCollect.delegate = self
                        
                    }
                    
                    
                })
                DispatchQueue.main.async{
                    self.instrumentTableView.reloadData()
                }
            })
        })
        
    
    if FIRAuth.auth()?.currentUser?.uid == nil {
    perform(#selector(handleLogout), with: nil, afterDelay: 0)
    }
    

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        performSegue(withIdentifier: "LogoutSegue", sender: self)
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    fileprivate var animationOptions: UIViewAnimationOptions = [.curveEaseInOut, .beginFromCurrentState]
    
    func
        out() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        performSegue(withIdentifier: "LogoutSegue", sender: self)
    }

    
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        if menuExpanded == true{
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.menuView.bounds = self.menuViewBounds
                self.menuView.frame.origin = self.menuViewOrigin
                //self.positionView.isHidden = true
                
            })

        } else {
            UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 2.0, options: animationOptions, animations: {
                self.menuView.bounds = self.shiftViewBounds
                self.menuView.frame.origin = self.shiftViewOrigin
                //self.positionView.isHidden = true
                
            })

        }
        menuExpanded = !self.menuExpanded
        
    }
    
    @IBAction func addMediaPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProfToAddMedia", sender: self)
    }
    @IBOutlet weak var addMedia: UIButton!
    @IBAction func invitesPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ProfToInvites", sender: self)
    }
    @IBOutlet weak var invitesMessagesButton: UIButton!
    
    @IBAction func updateInfoPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var updateInfoButton: UIButton!
    @IBOutlet weak var picCollect: UICollectionView!
    @IBOutlet weak var ONBLabel: UILabel!
    private func rotateView(targetView: UIView, duration: Double = 2.7) {
        if rotateCount == 4 {
            //performSegue(withIdentifier: "LaunchToScreen1", sender: self)
            ONBLabel.isHidden = true
            artistAllInfoView.isHidden = false
            
        } else {
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(M_PI))
            }) { finished in
                self.rotateCount = self.rotateCount + 1
                self.rotateView(targetView: targetView, duration: duration)
            }
        }
    }

    
    @available(iOS 2.0, *)
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        if item == tabBar.items?[0]{
            performSegue(withIdentifier: "ProfToFindMusicians", sender: self)
        } else if item == tabBar.items?[1]{
            performSegue(withIdentifier: "ProfToJoinBand", sender: self)
            
        } else if item == tabBar.items?[2]{
            
        } else {
            performSegue(withIdentifier: "redesignProfileToFeed", sender: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.currentCollect == "pic"{
            return self.picArray.count
        }else{
            if self.nsurlArray.count == 0{
                return 1
            }else{
                return self.nsurlArray.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell4Item: \(self.currentCollect)")
        if currentCollect != "pic"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureVidCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.indexPath = indexPath
            
            //self.curIndexPath.append(indexPath)
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            
            //self.curIndexPath.append(indexPath)
            
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != self.picCollect{
            if (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).videoURL?.absoluteString?.contains("youtube") == false && (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).videoURL?.absoluteString?.contains("youtu.be") == false {
                if (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playbackState == .playing {
                    (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.stop()
                    
                }else{
                    (self.videoCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playFromBeginning()
                }
                
            }
        }
        
        
        
    }
    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        
        
        if self.nsurlArray.count == 0{
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.layer.borderWidth = 1
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
            
            
            
            cell.videoURL =  self.nsurlArray[indexPath.row] as NSURL?
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
    func configureCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        
        cell.picImageView.image = self.picArray[indexPath.row]
        cell.deleteButton.isHidden = true
    }
    
    //TABLEVIEW FUNCTIONS********************
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        return self.instrumentArray.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //(tableView.cellForRow(at: indexPath) as ArtistCell).artistUID
        //self.cellTouchedArtistUID = (tableView.cellForRow(at: indexPath) as! ArtistCell).artistUID
        //performSegue(withIdentifier: "ArtistCellTouched", sender: self)
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstrumentCell", for: indexPath as IndexPath) as! InstrumentTableViewCell
        cell.instrumentLabel.text = self.instrumentArray[indexPath.row]
        cell.skillLabel.text =  self.skillArray[indexPath.row]
        cell.yearsLabel.text = self.yearsArray[indexPath.row]
        
        
        return cell
    }

    
}
extension UIImageView{
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 40
        self.layer.cornerRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}
extension UIButton{
    
    func dropShadow2() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 40
        self.layer.cornerRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}
extension UIView{
    
    func dropShadow3() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.9
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 40
        self.layer.cornerRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
    }
}

