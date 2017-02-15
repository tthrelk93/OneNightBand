//
//  MainNavigationViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/3/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation
import UIKit
import QuartzCore

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
    func finishedShowing(viewController: UIViewController) {
        if viewController.isBeingPresented && viewController.presentingViewController == self
        {
            self.view.backgroundColor = UIColor.clear.withAlphaComponent(1.0)
            
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}





class MainNavigationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource, PerformSegueInRootProtocol, DismissalDelegate  {
    

    
    
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
    
    var instrumentArray = [String]()
    var youtubeArray = [NSURL]()
   
    
    var ref = FIRDatabase.database().reference()
    var dictionaryOfInstruments: [NSDictionary] = [NSDictionary]()
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
    
    /*func setupSkillsLabel(){
        skillsLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        skillsLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -5).isActive = true
        skillsLabel.widthAnchor.constraint(equalTo: collectionView.widthAnchor).isActive = true
        skillsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

    }*/
    let picker = UIImagePickerController()
    
    @IBAction func addPicButtonPressed(_ sender: AnyObject) {
        
        self.view.backgroundColor = UIColor.black
        self.view.alpha = 0.6
        
        
        
           }
    var picArray = [UIImage]()
    var curCount = 0
    
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    /*override func viewDidLoad(){
        super.viewDidLoad()
        curCount = 0
        //let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
        //self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
       //profilePicCollectionView.delegate = self
        //profilePicCollectionView.dataSource = self
        //createSessionButton.setTitle("Menu", for: .normal)
        createSessionButton.titleLabel?.textAlignment = .center
        createSessionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        createSessionButton.layer.cornerRadius = 15
        createSessionButton.clipsToBounds = true
        createSessionButton.layer.masksToBounds = false
        
        self.bioTextView.delegate = self
        
            
        
        self.ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            self.bioTextView.text = value?["bio"] as! String
            self.navigationItem.title = (value?["name"] as! String)
        })
        

       
            
        self.ref.child("users").child(self.userID!).child("activeSessions").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                self.sessionsPlayed.text = String(snapshots.count)
                
            }
        })
        
        
            
        
        ref.child("users").child(userID!).child("instruments").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    
                    let tag = Tag()
                    tag.name = (snap.key)
                    tag.selected = true
                    self.tags.append(tag)
                }
            }
          
        })
        
        /*self.ref.child("users").child(self.userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    self.currentCollect = "youtube"
                    print(snap.value!)
                    self.youtubeArray.append(NSURL(string: snap.value as! String)!)
                    self.tempLink = NSURL(string: (snap.value as? String)!)
                    //self.tempTitle = snap.key
                    //self.YoutubeArray.append(snap.value as! String)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    //self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                }
            }
            if self.youtubeArray.count == 0{
                self.videoCollectEmpty = true
                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                
                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                //self.youtubeCollectionView.backgroundColor = UIColor.clear
                self.youtubeCollectionView.dataSource = self
                self.youtubeCollectionView.delegate = self
                
            }else{
                self.videoCollectEmpty = false
            }
            self.ref.child("users").child(self.userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                
                for snap in snapshots{
                    if let url = NSURL(string: snap.value as! String){
                        if let data = NSData(contentsOf: url as URL){
                            self.picArray.append(UIImage(data: data as Data)!)
                            
                            
                        }
                    }
                }
                for snap in snapshots{
                    print(snap.value!)
                    self.currentCollect = "pic"
                    let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                    self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                    self.profilePicCollectionView.backgroundColor = UIColor.clear
                    self.profilePicCollectionView.dataSource = self
                    self.profilePicCollectionView.delegate = self
                }
                if self.picArray.count == 0{
                    if let url = NSURL(string: snapshot.value as! String){
                        if let data = NSData(contentsOf: url as URL){
                            self.picArray.append(UIImage(data: data as Data)!)
                            self.currentCollect = "pic"
                            let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                            self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                            self.profilePicCollectionView.backgroundColor = UIColor.clear
                            self.profilePicCollectionView.dataSource = self
                            self.profilePicCollectionView.delegate = self
                            
                        }
                    }
                }
            })*/

                /*DispatchQueue.main.async{
        print("pArray: \(self.picArray)")
        self.currentCollect = "pic"
        //self.videoCollectEmpty = false
        for _ in self.picArray{
            //self.tempLink = NSURL(string: (snap.value as? String)!)
            
            //self.YoutubeArray.append(snap.value as! String)
            
            let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
            self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
            
            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
            self.profilePicCollectionView.backgroundColor = UIColor.clear
            self.profilePicCollectionView.dataSource = self
            self.profilePicCollectionView.delegate = self
            
        }
        }*/

        

            /*let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
         
            for snap in snapshots{
                if let url = NSURL(string: snap.value as! String){
                    if let data = NSData(contentsOf: url as URL){
                        self.picArray.append(UIImage(data: data as Data)!)
                        
                        
                    }
                }
            }
            for snap in snapshots{
                print(snap.value!)
                self.currentCollect = "pic"
                let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                self.profilePicCollectionView.backgroundColor = UIColor.clear
                self.profilePicCollectionView.dataSource = self
                self.profilePicCollectionView.delegate = self
            }
            if self.picArray.count == 0{
                if let url = NSURL(string: snapshot.value as! String){
                    if let data = NSData(contentsOf: url as URL){
                        self.picArray.append(UIImage(data: data as Data)!)
                        self.currentCollect = "pic"
                        let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                        self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                        self.profilePicCollectionView.backgroundColor = UIColor.clear
                        self.profilePicCollectionView.dataSource = self
                        self.profilePicCollectionView.delegate = self
                        
                    }
                }
            }
        })*/


        
    
    
    


    

        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
       
        
        
    }*/
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        
    }
    
    
    var viewDidAppearBool = false
    
    /*var indicator = UIActivityIndicatorView()
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.backgroundColor = UIColor.clear
        self.view.alpha = 1.0
        createSessionButton.titleLabel?.textAlignment = .center
        createSessionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        createSessionButton.layer.cornerRadius = 15
        createSessionButton.clipsToBounds = true
        createSessionButton.layer.masksToBounds = false
        
        self.bioTextView.delegate = self
        
        var group = DispatchGroup()
        if viewDidAppearBool == false{
            //recentlyAddedVidArray.removeAll()
            //youtubeDataArray.removeAll()
            //needToRemove = false
            //needToRemovePic = false
            //imagePicker.delegate = self
            // picker.delegate = self
            //curCount = 0
            
            
        self.ref.child("users").child(self.userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
                group.enter()
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    self.currentCollect = "youtube"
                    
                    for snap in snapshots{
                        
                        self.youtubeArray.append(NSURL(string: snap.value as! String)!)
                        
                        
                    }
                    if self.youtubeArray.count == 0{
                        self.videoCollectEmpty = true
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.youtubeCollectionView.backgroundColor = UIColor.clear
                        self.youtubeCollectionView.dataSource = self
                        self.youtubeCollectionView.delegate = self
                        
                    }else{
                        self.videoCollectEmpty = false
                        for snap in snapshots{
                            self.tempLink = NSURL(string: (snap.value as? String)!)
                            
                            //self.YoutubeArray.append(snap.value as! String)
                            
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            
                            self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.youtubeCollectionView.backgroundColor = UIColor.clear
                            self.youtubeCollectionView.dataSource = self
                            self.youtubeCollectionView.delegate = self
                            //self.curCount += 1
                            
                        }
                    }
                }
                
                self.ref.child("users").child(self.userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    self.bioTextView.text = value?["bio"] as! String
                    self.navigationItem.title = (value?["name"] as! String)
                })
                
                
                
                
                self.ref.child("users").child(self.userID!).child("activeSessions").observeSingleEvent(of: .value, with: {(snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        self.sessionsPlayed.text = String(snapshots.count)
                        
                    }
                })
        
            group.leave()
            
                
                group.enter()
            self.ref.child("users").child(self.userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    
                    for snap in snapshots{
                        
                        if let url = NSURL(string: snap.value as! String){
                            if let data = NSData(contentsOf: url as URL){
                                self.picArray.append(UIImage(data: data as Data)!)
                                
                            }
                            
                        }
                    }
                }
                    print("pArray: \(self.picArray)")
            
                    self.videoCollectEmpty = false
                    for pic in self.picArray{
                        //self.tempLink = NSURL(string: (snap.value as? String)!)
                        self.currentCollect = "pic"
                        //self.YoutubeArray.append(snap.value as! String)
                        
                        let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                        self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                        self.profilePicCollectionView.backgroundColor = UIColor.clear
                        self.profilePicCollectionView.dataSource = self
                        self.profilePicCollectionView.delegate = self
                        
                    }
            })
            group.leave()
            })
           
            

            self.viewDidAppearBool = true
            

        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
    }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
            /*var delay: Double = 0
            for i in 0..<10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    // Put your code which should be executed with a delay here
                    //let image = self.logoImage[i]
                    //self.imageView.image = image
                    print(delay)
                })
                delay += 0.8
            }*/
        
    
        
        
        
        
        
        
        

    }
    
    
    
    var tempLink: NSURL?
     //let userID = FIRAuth.auth()?.currentUser?.uid
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    
    var videoCollectEmpty: Bool?
    var currentCollect: String?
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.currentCollect == "pic"{
            return self.picArray.count
        }else{
            if self.youtubeArray.count == 0{
                return 1
            }else{
                return self.youtubeArray.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        
    }
    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        if self.videoCollectEmpty == true{
            //cell.layer.borderColor = UIColor.white.cgColor
            //cell.layer.borderWidth = 2
            cell.videoURL = nil
            cell.youtubePlayerView.isHidden = true
            //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
            cell.removeVideoButton.isHidden = true
            cell.noVideosLabel.isHidden = false
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.white.cgColor
            

        }else{
            //cell.layer.borderColor = UIColor.clear.cgColor
            //cell.layer.borderWidth = 0
            cell.youtubePlayerView.isHidden = false
            cell.videoURL = self.youtubeArray[indexPath.row]
            cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
            cell.removeVideoButton.isHidden = true
             cell.noVideosLabel.isHidden = true
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
            
    

    
    @IBOutlet weak var sessionsPlayed: UILabel!
    
    func createSessionButtonSelected() {
        //self.view.backgroundColor = UIColor.black
        //self.view.alpha = 0.6
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
            .setAnimationOrigin(CGPoint(x: createSessionButton.center.x,y: (createSessionButton.center.y + 65.0)))
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
}

