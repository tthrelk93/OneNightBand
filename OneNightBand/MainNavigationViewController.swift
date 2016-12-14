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
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

class MainNavigationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource, PerformSegueInRootProtocol, DismissalDelegate  /*,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout*/{
    
    func prepareForSegue(segue: UIStoryboardSegue, sender _: AnyObject?) {
        if let vc = segue.destination as? Dismissable
        {
            vc.dismissalDelegate = self
        }
    }
    
    
    @IBOutlet weak var profilePicCollectionView: UICollectionView!
    //@IBOutlet weak var flowLayout: FlowLayout!
    //@IBOutlet weak var collectionView: UICollectionView!
   
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    //@IBOutlet weak var profilePicture: UIImageView!
    //@IBOutlet weak var photoSelectorButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    
    
    @IBOutlet weak var createSessionButton: ALRadialMenu!
    //@IBOutlet weak var editBioUpdateButton: UIButton!
    //@IBOutlet weak var editBioLabel: UILabel!
    
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
        self.view.alpha = 0.8
        
        
           }
    var picArray = [String]()
    var curCount = 0
    override func viewDidLoad(){
        super.viewDidLoad()
        curCount = 0
        
        
        profilePicCollectionView.delegate = self
        createSessionButton.setTitle("Session\n Manager", for: .normal)
        createSessionButton.titleLabel?.textAlignment = .center
        createSessionButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        //let navBar:UINavigationBar = UINavigationBar()
        //navBar.backgroundColor = UIColor.black
        //view.addSubview(navBar)
        
        
        createSessionButton.layer.cornerRadius = 15
        createSessionButton.clipsToBounds = true
        createSessionButton.layer.masksToBounds = false
        //view.addSubview(skillsLabel)
        //setupSkillsLabel()
        //collectionView.showsVerticalScrollIndicator = true
        
        //self.editBioUpdateButton.layer.cornerRadius = 5
        //self.editBioUpdateButton.isHidden = true
        //self.editBioLabel.isHidden = false
        //self.editBioUpdateButton.titleLabel?.text = "Save Changes"
        //editBioUpdateButton.setTitleColor(UIColor.orange, for: .normal)
        //editBioUpdateButton.titleLabel?.textColor = UIColor.orange
        
        self.bioTextView.delegate = self
        
       
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).child("instruments").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    let tag = Tag()
                    tag.name = (snap.value! as! String)
                    tag.selected = true
                    self.tags.append(tag)
                }
            }
           /* let cellNib = UINib(nibName: "TagCell", bundle: nil)
            self.collectionView.register(cellNib, forCellWithReuseIdentifier: "TagCell")
            self.collectionView.backgroundColor = UIColor.clear
            self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
            
            //self.flowLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8)
            self.collectionView.dataSource = self
            self.collectionView.delegate = self*/
            
        })
    

        
        
        //print (instrumentArray)
        //initializing TagCell and creating a cell for each item in array TAGS
        
        //add logout button to Nav Bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
        //set image picker delegate and then set profile pic constraints
        
        /*profilePicture.layer.borderWidth = 2
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.clipsToBounds = true
        
        photoSelectorButton.layer.masksToBounds = false
        photoSelectorButton.layer.cornerRadius = photoSelectorButton.frame.width/2
        photoSelectorButton.clipsToBounds = true*/
        
        //creating and adding blur effect to subview
        /*let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundImage.addSubview(blurEffectView)*/
        //let gesture = UITapGestureRecognizer(target: self, action: #selector(showMenu()))
        //view.addGestureRecognizer(gesture)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadYoutubeCollection()
        loadPicCollection()
    }
    var tempLink: NSURL?
    
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    func loadYoutubeCollection(){
        let userID = FIRAuth.auth()?.currentUser?.uid

        ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                
                for snap in snapshots{
                    self.currentCollect = "youtube"
                    
                    self.youtubeArray.append(NSURL(string: snap.value as! String)!)
                    self.tempLink = NSURL(string: (snap.value as? String)!)
                    //self.tempTitle = snap.key
                    //self.YoutubeArray.append(snap.value as! String)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                    
                    
                    
                }
                
                
                
            }
        })

    }
    var currentCollect: String?
    func loadPicCollection(){
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in

            let value = snapshot.value as? NSDictionary
            self.bioTextView.text = value?["bio"] as! String
            self.navigationItem.title = (value?["name"] as! String)
            
          self.ref.child("users").child(userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
               let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                
                for snap in snapshots{
                    self.picArray.append(snap.value as! String)
                }
                if self.picArray.count == 0{
                    self.picArray.append(snapshot.value as! String)
                }
                for _ in self.picArray{
                    
                    self.currentCollect = "pic"
                    let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                    self.profilePicCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                    self.profilePicCollectionView.backgroundColor = UIColor.clear
                    self.profilePicCollectionView.dataSource = self
                    self.profilePicCollectionView.delegate = self
                    self.curCount += 1

                }
                
            })
            
            
            
            /*if let profileImageUrl = selfpicArray.first {
             self.profilePicture.loadImageUsingCacheWithUrlString(profileImageUrl)
             }*/
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.currentCollect == "pic"{
            return self.curCount
        }else{
            return self.youtubeArray.count
        }
            }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentCollect == "pic"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
        
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
            
        
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            
            self.configureVidCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            
            return cell
        }
    }
            
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*let cell = collectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell
         if cell.isPlaying == false{
         cell.youtubePlayerView.play()
         cell.isPlaying = true
         cell.isPaused = false
         }else{
         cell.youtubePlayerView.pause()
         cell.isPlaying = false
         cell.isPaused = true
         }*/
        
    }
    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        cell.videoURL = self.tempLink
        cell.youtubePlayerView.loadVideoURL(videoURL: self.tempLink!)
    }
    func configureCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        print("ip: \(indexPath.row)")
            cell.picImageView.loadImageUsingCacheWithUrlString(self.picArray[indexPath.row])
        switch UIScreen.main.bounds.width{
        case 320:
            
            cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width:320, height:267)
            
        case 375:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:375,height:267)
            
            
        case 414:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:267)
            
        default:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:267)
            
            
            
        }

        
            
            
        }
            
    

    
    
    func createSessionButtonSelected() {
        self.view.backgroundColor = UIColor.black
        self.view.alpha = 0.8
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateSessionPopup") as! CreateSessionPopup
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        
            }
    func currentSessionsButtonSelected(){
        performSegue(withIdentifier: "ProfileToSessionCollection", sender: self)
        /*let currentSessionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CurrentSessionsVC") as! CurrentSessionCollectionView
        self.addChildViewController(currentSessionsVC)
        currentSessionsVC.view.frame = self.view.frame
        self.view.addSubview(currentSessionsVC.view)
        currentSessionsVC.didMove(toParentViewController: self)*/
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
                button.backgroundColor = UIColor.clear//init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1)
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                //button.widthAnchor.constraint(equalToConstant: 150)
                //button.heightAnchor.constraint(equalToConstant: 150)
                
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
                button.backgroundColor = UIColor.clear//init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1)
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                //button.widthAnchor.constraint(equalToConstant: 150)
                //button.heightAnchor.constraint(equalToConstant: 150)
                
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
                button.backgroundColor = UIColor.clear//init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1)
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                //button.widthAnchor.constraint(equalToConstant: 150)
                //button.heightAnchor.constraint(equalToConstant: 150)
                
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
                button.backgroundColor = UIColor.clear//init(red: CGFloat(colorArray[i][0]/255.0), green: CGFloat(colorArray[i][1]/255.0), blue: CGFloat(colorArray[i][2]/255.0), alpha: 1)
                button.layer.masksToBounds = false
                button.layer.cornerRadius = button.frame.height/2
                button.clipsToBounds = true
                //button.widthAnchor.constraint(equalToConstant: 150)
                //button.heightAnchor.constraint(equalToConstant: 150)
                
                buttons.append(button)

                

                        }
        }
        
        return buttons
    }
    
    func showMenu() {
        _ = createSessionButton
            .setButtons(generateButtons())
            .setDelay(0.05)
            .setAnimationOrigin(CGPoint(x: createSessionButton.center.x,y: (createSessionButton.center.y + 70.0)))
            .presentInView(view)
            }




       
    
    
    /*//CollectionView Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath as IndexPath) as! TagCell
        self.configureCell(cell: cell, forIndexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath as IndexPath, animated: false)
        tags[indexPath.row].selected = !tags[indexPath.row].selected
        self.collectionView.reloadData()
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: NSIndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = tag.name
        cell.tagName.textColor = tag.selected ? UIColor.white : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        cell.backgroundColor = tag.selected ? UIColor.orange : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }*/

    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //self.editBioUpdateButton.isHidden = false
        //self.editBioUpdateButton.isEnabled = true
        //self.editBioLabel.isHidden = true
        }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        }

   
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        //let loginController = CreateAccountViewController()
        performSegue(withIdentifier: "LogoutSegue", sender: self)
        //present(loginController, animated: true, completion: nil)
    }


    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profilePicture.image = image
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
            
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }*/

        
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

