//
//  MainNavigationViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/3/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

//import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation
import UIKit
import QuartzCore
import SwiftOverlays


protocol DismissalDelegate : class
{
    func finishedShowing(viewController: UIViewController);
}



protocol Dismissable : class
{
    weak var dismissalDelegate : DismissalDelegate? { get set }
}

extension DismissalDelegate where Self: UIViewController
{
    }





class MainNavigationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource, PerformSegueInRootProtocol, DismissalDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var instrumentTableView: UITableView!

    //func view
    
    func prepareForSegue(segue: UIStoryboardSegue, sender _: AnyObject?) {
            if let vc = segue.destination as? Dismissable
            {
                vc.dismissalDelegate = self
            }
    }
    @IBOutlet weak var profilePicCollectionView: UICollectionView!
   
   
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var createSessionButton: ALRadialMenu!
    
    
    var sizingCell: PictureCollectionViewCell?
    var sizingCell2: VideoCollectionViewCell?
    var sizingCell3: VideoCollectionViewCell?
    
    var instrumentArray = [String]()
    var youtubeArray = [NSURL]()
    var nsurlArray = [NSURL]()
    var ref = FIRDatabase.database().reference()
    var dictionaryOfInstruments = [String: Any]()
    var tags = [Tag]()
    
    let skillsLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.text = "Skills"
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        return label
    }()
    
    let picker = UIImagePickerController()
    
    @IBAction func addPicButtonPressed(_ sender: AnyObject) {
        
        self.view.backgroundColor = UIColor.black
        self.view.alpha = 0.6
    }
    
    var picArray = [UIImage]()
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad(){
        super.viewDidLoad()
         //loadVidFromPhone()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        SwiftOverlays.showBlockingTextOverlay("Finalizing")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        profilePicCollectionView.collectionViewLayout = layout
        

    }
    
    var vidFromPhoneArray = [NSURL]()
    var viewDidAppearBool = false
    var isYoutubeCell: Bool?
    var skillArray = [String]()
   // let group = DispatchGroup()
    //let backgroundQ = DispatchQueue.global(qos: .default)
    var nsurlDict = [NSURL: String]()
    override func viewDidAppear(_ animated: Bool) {
        SwiftOverlays.removeAllBlockingOverlays()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.backgroundColor = UIColor.clear
        //self.shadeView.isHidden = true
        self.view.alpha = 1.0
        createSessionButton.titleLabel?.textAlignment = .center
        createSessionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        createSessionButton.layer.cornerRadius = 15
        createSessionButton.clipsToBounds = true
        createSessionButton.layer.masksToBounds = false
        self.bioTextView.delegate = self
        //let backgroundQ = DispatchQueue.global(attributes: .qosDefault)
        
        
        if viewDidAppearBool == false{
            
            
            self.ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    //fill datasources for collectionViews
                    for snap in snapshots{
                        if snap.key == "media"{
                            let mediaSnaps = snap.children.allObjects as? [FIRDataSnapshot]
                            for m_snap in mediaSnaps!{
                                //fill youtubeArray
                                if m_snap.key == "youtube"{
                                    for y_snap in m_snap.value as! [String]
                                    {
                                        
                                        self.youtubeArray.append(NSURL(string: y_snap)!)
                                        self.nsurlArray.append(NSURL(string: y_snap)!)
                                        self.nsurlDict[NSURL(string: y_snap)!] = "y"
                                    }
                                }
                                //fill vidsFromPhone array
                                else{
                                    for v_snap in m_snap.value as! [String]
                                    {
                                        self.vidFromPhoneArray.append(NSURL(string: v_snap)!)
                                        self.nsurlArray.append(NSURL(string: v_snap)!)
                                        self.nsurlDict[NSURL(string: v_snap)!] = "v"
                                    }
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
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self

                }
                for vid in self.nsurlArray{
                    
                        // Put your code which should be executed with a delay here
                    self.currentCollect = "youtube"
                    
                    self.tempLink = vid
                       
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                }
                
                
               self.viewDidAppearBool = true
            
            self.ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                
                self.bioTextView.text = value?["bio"] as! String
                self.navigationItem.title = (value?["name"] as! String)
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
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    self.sessionsPlayed.text = String(snapshots.count)
                    
                }
                for _ in self.picArray{
                    self.currentCollect = "pic"
                    //self.tempLink = NSURL(string: (snap.value as? String)!)
                    
                    //self.YoutubeArray.append(snap.value as! String)
                    
                    let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                    self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                    self.profilePicCollectionView.backgroundColor = UIColor.clear
                    self.profilePicCollectionView.dataSource = self
                    self.profilePicCollectionView.delegate = self
                    
                }
                

            })
                DispatchQueue.main.async{
                    self.instrumentTableView.reloadData()
                }
             })
            })
            //self.viewDidAppearBool = true
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }

        }
        
        
        
        
        
        
        
        
        
        
    
    

                
   
    
    
  
    
    var yearsArray = [String]()
    var playingYearsArray = ["1","2","3","4","5+","10+"]
    var playingLevelArray = ["beginner", "intermediate", "advanced", "expert"]
    var tempLink: NSURL?
     //let userID = FIRAuth.auth()?.currentUser?.uid
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    
    var videoCollectEmpty: Bool?
    var currentCollect: String?
    
    
    //@IBOutlet weak var shadeView: UIView!
    
    
    func finishedShowing(viewController: UIViewController) {
        //if viewController.isBeingPresented && viewController.presentingViewController == self
        //{
        //self.shadeView.isHidden = true
        self.view.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
        
        self.dismiss(animated: true, completion: nil)
        return
        //}
        
        // self.navigationController?.popViewController(animated: true)
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
        if collectionView != self.profilePicCollectionView{
        if (self.youtubeCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).videoURL?.absoluteString?.contains("youtube") == false {
            if (self.youtubeCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playbackState == .playing {
                (self.youtubeCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.stop()
                
            }else{
                (self.youtubeCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playFromBeginning()
            }
            
        }
        }
        

        
    }
    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        
       
            if self.nsurlArray.count == 0{
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
       /* switch UIScreen.main.bounds.width{
        case 320:
            
            cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width:320, height:267)
            
        case 375:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:375,height:267)
            
            
        case 414:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:267)
            
        default:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:267)
            
            
            
        }*/
 
        }
    
    
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

            
    

    
    @IBOutlet weak var sessionsPlayed: UILabel!
    
    func createSessionButtonSelected() {
        //self.view.backgroundColor = UIColor.black
        //self.view.alpha = 0.6
        //shadeView.isHidden = false
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateSessionPopup") as! CreateSessionPopup
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        
            }
    func currentSessionsButtonSelected(){
        performSegue(withIdentifier: "ProfileToSessionCollection", sender: self)
       
    }
    func sessionInvitesButtonSelected(){
        performSegue(withIdentifier: "MainNavToSessionInvites", sender: self)
    }
    func sessionFeedButtonSelected(){
        performSegue(withIdentifier: "ProfileToSessionFeed", sender: self)
    }

    var menuText = ["Session\n Invites", "My\n Sessions", "Create\n Session", "Session\n Feed"]
    func generateButtons() -> [ALRadialMenuButton] {
        
        var buttons = [ALRadialMenuButton]()
        let colorArray = [[221.0, 117.0, 46.0],[225.0,160.0,47.0],[124.0,183.0,61.0],[67.0,181.0,105.0]]
        for i in 0..<4 {
            switch UIScreen.main.bounds.width{
            case 320:
                let button = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
                button.home = "mainNav"
                button.homeScreenSize = Double(self.view.frame.width)
                button.index = i
                button.delegate = self
                button.setTitle(menuText[i], for: .normal)
                button.setTitleColor(UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1), for: .normal)
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont(name: "System Light", size: 10)
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1).cgColor
                button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                button.backgroundColor = UIColor.clear
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
   
                buttons.append(button)

            case 375:
                let button = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
                button.home = "mainNav"
                button.homeScreenSize = Double(self.view.frame.width)
                button.index = i
                button.delegate = self
                button.setTitle(menuText[i], for: .normal)
                button.setTitleColor(UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1), for: .normal)
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont(name: "System Light", size: 20)
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1).cgColor
                button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                button.backgroundColor = UIColor.clear
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                buttons.append(button)

            case 414:
                let button = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
                button.home = "mainNav"
                button.homeScreenSize = Double(self.view.frame.width)
                button.index = i
                button.delegate = self
                button.setTitle(menuText[i], for: .normal)
                button.setTitleColor(UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1), for: .normal)
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont(name: "System Light", size: 20)
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1).cgColor
                button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                button.backgroundColor = UIColor.clear
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                
                buttons.append(button)

            default:
                let button = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
                button.home = "mainNav"
                button.homeScreenSize = Double(self.view.frame.width)
                button.index = i
                button.delegate = self
                button.setTitle(menuText[i], for: .normal)
                button.setTitleColor(UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1), for: .normal)
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont(name: "System Light", size: 20)
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1).cgColor
                button.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                button.backgroundColor = UIColor.clear
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                
                buttons.append(button)
            }
        }
        
        return buttons
    }
    
    func showMenu() {
        _ = createSessionButton
            .setButtons(generateButtons())
            .setDelay(0.05)
            .setAnimationOrigin(CGPoint(x: createSessionButton.center.x,y: (createSessionButton.center.y)))
            .presentInView(view)
            }



    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
                }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        }

   
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
       
        performSegue(withIdentifier: "LogoutSegue", sender: self)
    }

    
    @IBAction func editBioUpdateButtonPressed(_ sender: AnyObject) {
        if let user = FIRAuth.auth()?.currentUser?.uid{
            let ref = FIRDatabase.database().reference()
            let userRef = ref.child("users").child(user)
            var dict = [String: AnyObject]()
            dict["bio"] = bioTextView.text as AnyObject?
            userRef.updateChildValues(dict, withCompletionBlock: {(err, ref) in
                if err != nil {
                    print(err)
                    return
                }
            })
 as Any     
        }else{
            //need to sign them out
            return
        }
        //editBioUpdateButton.isHidden = true
        //editBioLabel.isHidden = false
   
    }
    
    @IBAction func sessionMenuTouched(_ sender: AnyObject) {
        //createSessionButton.zoomIn()
        //self.bioTextView.alpha = 0.3
        createSessionButton.setTitle("", for: .normal)
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: [], animations: {
            let bounds = self.createSessionButton.frame
            self.createSessionButton.bounds = CGRect(x: bounds.origin.x - 30, y: bounds.origin.y, width: bounds.size.width - bounds.size.width, height: bounds.size.height - bounds.size.height)
            }, completion: nil)
        
    
        showMenu()
    
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if currentCollect == "pic"{
            
                return UIEdgeInsetsMake(0, 0, 0, 0)
            /*}else{
                let totalCellWidth = (self.sizingCell?.frame.width)! * CGFloat(self.picArray.count)
                let totalSpacingWidth = 10 * (self.picArray.count - 1)
                
                let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
                let rightInset = leftInset
                return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
            }*/
        } else{
            return UIEdgeInsetsMake(0, collectionView.contentInset.left, 0, collectionView.contentInset.right)
        }
    }

    
}

