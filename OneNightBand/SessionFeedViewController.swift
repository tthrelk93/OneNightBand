//
//  SessionFeedViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/3/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftOverlays
import YNDropDownMenu
//import Firebase


protocol FeedDismissalDelegate : class
{
    func finishedShowing(viewController: UIViewController);
    
}

protocol FeedDismissable : class
{
    weak var feedDismissalDelegate : FeedDismissalDelegate? { get set }
}

extension FeedDismissalDelegate where Self: UIViewController
{
    func finishedShowing(viewController: UIViewController) {
        if viewController.isBeingPresented && viewController.presentingViewController == self
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        //self.navigationController?.popViewController(animated: true)
    }
}




class SessionFeedViewController: UIViewController, UIGestureRecognizerDelegate,UINavigationControllerDelegate, FeedDismissalDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var sessionViewCountLabel: UILabel!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var backgroundGuitarImage: UIImageView!
    
    
    var sessionArray = [Session]()
    var ref = FIRDatabase.database().reference()
    var firstTouch = CGPoint()
    var viewPins: NSMutableArray!
    var scrollOffset = CGFloat()
    var currentButton: ONBGuitarButton?
    var player:Player?
    
    
    @IBOutlet weak var playerContainerView: PlayerView!
    
    
    @IBOutlet weak var artistTableView: UITableView!
    @IBOutlet weak var sessInfoView: UIView!
    //var ref = FIRDatabase.database().reference()
    var currentVideoURL: URL?
    let kFretY = 383
    
    override func viewDidAppear(_ animated: Bool) {
        //self.player = storyboard.view
        self.player = Player()
        //var currentItem = player?.playerItem
        //print(currentItem)
        
        //self.currentButton = currentButtonFunc()
        
        
        self.player?.view.frame = self.sessionImageView.frame
        //self.player?.view.topAnchor.constraint(equalTo: se self.view.topAnchor).isActive = true
        //self.player?.view.heightAnchor.constraint(equalToConstant: self.view.frame.height/3.14).isActive = true
        //self.player?.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        //self.playerContainerView.viewController()?.addChildViewController(player!)
        //self.playerContainerView.viewController().
        //self.player?.delegate = self
        
        /*switch UIScreen.main.bounds.width{
        case 320:
            self.player?.view.frame = CGRect(x: 35,y:50,width:250,height:130)
            
        case 375:
            self.player?.view.frame = CGRect(x: 40,y:85,width:300,height:200)
            
            
        case 414:
            self.player?.view.frame = CGRect(x: 33,y:100,width:350,height:250)
            
        default:
            self.player?.view.frame = CGRect(x: 60,y:140,width:350,height:250)
            
            
            
        }*/
        
        
        
        

        
        
        self.sessionInfoView.autoresizesSubviews = true
        
        self.addChildViewController(self.player!)
        sessionInfoView.addSubview((self.player?.view)!)
       
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.playerItem)
        
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        SwiftOverlays.removeAllBlockingOverlays()
        
        if sessionArray.count != 0{
            for session in 0...sessionArray.count-1{
                var tempDict = [String:Int]()
                tempDict["views"] = viewArray[session]
                ref.child("sessionFeed").child(sessFeedKeyArray[session]).updateChildValues(tempDict)
            }
        }
    }
    
    func addNewSession(){
        performSegue(withIdentifier: "FeedToUpload", sender: self)
    }
    func backToNav(){
        SwiftOverlays.showBlockingTextOverlay("Loading Your Profile")
        performSegue(withIdentifier: "BackToMainNav", sender: self)
    }
    @IBOutlet weak var sessionViewsLabel2: UILabel!
    @IBOutlet weak var sessionNameLabel2: UILabel!
    var dropMenu: YNDropDownMenu?
    var sessionsInDatabase = [Session]()
    var sessFeedKeyArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.sessInfoView.isHidden = true
        dropMenu = YNDropDownMenu(frame:sizeView.frame, dropDownViews: [sessInfoView], dropDownViewTitles: ["Session Details"])
        dropMenu?.labelFontSize = 30.0
       //dropMenu.setLabelFontWhen(normal: UIFont.systemFont(ofSize: 20), selected: UIFont.boldSystemFont(ofSize: 20), disabled: UIFont.systemFont(ofSize: 20))
        dropMenu?.autoresizesSubviews = true
        dropMenu?.clipsToBounds = true
       // dropMenu.changeMenuTitleAt(index: 0, title: "hello")
        dropMenu?.setImageWhen(normal: UIImage(named: "dropNoSelect"), selected: UIImage(named: "dropSelect"), disabled: UIImage(named: "dropNoSelect"))
       dropMenu?.backgroundBlurEnabled = false
        dropMenu?.backgroundColor = UIColor.clear
        self.view.addSubview(dropMenu!)
        //self.view.bringSubview(toFront: dropMenu!)
        //self.addSubview(view)
        //self.guitarPickButton.isHidden = true
        guitarPickButton.setImage(UIImage(named: "s_solid_white-1"), for: .normal)
        self.ref.child("sessions").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    let tempSess = Session()
                    let dictionary = snap.value as? [String: AnyObject]
                    tempSess.setValuesForKeys(dictionary!)
                    self.sessionsInDatabase.append(tempSess)
                }
            }
        })
        navigationItem.title = "Session Feed"
        let profileButton = UIBarButtonItem(title: "Profile", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SessionFeedViewController.backToNav)) // navigationItem.leftBarButtonItem
        navigationItem.leftBarButtonItem = profileButton
                let uploadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(SessionFeedViewController.addNewSession))
        navigationItem.rightBarButtonItem = uploadButton
        
        
        
        self.ref.child("sessionFeed").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount != 0{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshots{
                    let tempSess = Session()
                    let dictionary = snap.value as? [String: AnyObject]
                    
                 
                    tempSess.setValuesForKeys(dictionary!)
                    self.viewArray.append(tempSess.views)
                    self.sessionArray.append(tempSess)
                    self.sessFeedKeyArray.append(snap.key as String)
                        }
                    }
            }
        
            
                
            self.view.clipsToBounds = true
            self.scrollOffset = 0
            
            self.viewPins = NSMutableArray()
            //for i in -27..<7{
            for i in 0..<self.sessionArray.count{
                let button = ONBGuitarButton()
                button.initWithLane(lane: Int(arc4random_uniform(6)))
                button.setYPosition(yPosition: (3 - CGFloat(i)) * 2.3)
                //button.image = UIImage(named:"GuitarPin_Red.png")
                button.sessionFeedKey = self.sessFeedKeyArray[i]
                
                
                
                self.view.addSubview(button)
                self.viewPins.add(button)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.scrollToPin))
                
                tap.numberOfTapsRequired = 1
                button.addGestureRecognizer(tap)
                button.isUserInteractionEnabled = true
                button.session = self.sessionArray[i]
                button.sessionViews = self.viewArray[i]
                    
            
            }
            for button in self.viewPins{
                print((button as! ONBGuitarButton)._baseX)
                print((button as! ONBGuitarButton).lane)
            }

        })
        
                //self.currentButton = self.currentButtonFunc()

            //self.displaySessionInfo()
        
        
        
        

        // Do any additional setup after loading the view.
    }
    
    var viewArray = [Int]()
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "FeedToUpload"{
            if let vc = segue.destination as? FeedDismissable
            {
                vc.feedDismissalDelegate = self
            }
        }
        if segue.identifier == "FeedToArtistProf"{
            if let vc = segue.destination as? ArtistProfileViewController{
                //print(self.cellTouchedArtistUID)
                vc.artistUID = self.cellTouchedArtistUID
            }
        }

    }
    
    
   

    
    
    func scrollToPin(sender: UITapGestureRecognizer){
        let button = sender.view //as! ONBGuitarButton
        let scrollDistance = 13 - sqrt((button?.center.y)! - 200)
       
        UIView.animate(withDuration: 0.5, animations:{self.viewPins.forEach { button in
            (button as! ONBGuitarButton).offsetYPosition(offset: scrollDistance)
            self.scrollOffset += scrollDistance
            }

            }, completion: {
                (value: Bool) in
                self.displaySessionInfo()
        })
    }
        //func goToSession()
    @IBOutlet weak var guitarPickButton: UIButton!
  
    @IBAction func guitarPickPressed(_ sender: Any) {
        if guitarPickButton.imageView?.image == UIImage(named: "s_solid_white-1.png"){
            guitarPickButton.setImage(UIImage(named: "s_goldenrod-1.png"), for: .normal)
        }else{
            guitarPickButton.setImage(UIImage(named: "s_solid_white-1.png"), for: .normal)
        }
        
    }
    var sessionArtists = [Artist]()
    public func tableView(_
        : UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        
        return artistDict.keys.count
    }
    var cellTouchedArtistUID = String()
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //(tableView.cellForRow(at: indexPath) as ArtistCell).artistUID
        self.cellTouchedArtistUID = (tableView.cellForRow(at: indexPath) as! ArtistCell).artistUID
        print(self.cellTouchedArtistUID)
        performSegue(withIdentifier: "FeedToArtistProf", sender: self)
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath as IndexPath) as! ArtistCell
        let tempArtist = Artist()
        //let userID = FIRAuth.auth()?.currentUser?.uid
        var tempArtistArray = [String]()
        var tempInstrumentArray = [String]()
        for (key, value) in artistDict{
            tempArtistArray.append(key)
            tempInstrumentArray.append(value)
        }
        
        ref.child("users").child(tempArtistArray[indexPath.row]).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
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
            
            cell.artistNameLabel.text = tempArtist.name
            cell.artistInstrumentLabel.text = "test"
            cell.artistImageView.loadImageUsingCacheWithUrlString(tempArtist.profileImageUrl.first!)
            cell.artistInstrumentLabel.text = tempInstrumentArray[indexPath.row]
            
        })
        return cell
    }
    
    @IBOutlet weak var sizeView: UIView!

    
    var artistDict = [String: String]()
    
    
    func displaySessionInfo(){
         
        artistDict.removeAll()
        let cButton = currentButtonFunc()
        //if cButton.isDisplayed == true{
            self.player?.playerView.isHidden = false
            //sessInfoView.isHidden = false
            //dropMenu?.dropDownViewTitles = [(cButton.session?.sessionName!)!]
            dropMenu?.backgroundColor = UIColor.clear
            //dropMenu?.bringSubview(toFront: sessInfoView)
            //dropMenu.view
            //dropMenu?.dropDownViewTitles.append(cButton.sessionName)
            //changeMenu(title: cButton.sessionName, at: 0)
            
            let tempLabel = (cButton.session?.sessionName)!
            sessionNameLabel.text = tempLabel
        
            sessionViewCountLabel.text = "Views: \(String(describing: cButton.sessionViews!))"
                sessionNameLabel2.text = tempLabel
                sessionViewsLabel2.text = "Views: \(String(describing: cButton.sessionViews!))"
                for (key, value) in (cButton.session?.sessionArtists)!{
                    self.artistDict[key] = value as? String
                }
            
                for _ in artistDict.keys{
                    let cellNib = UINib(nibName: "ArtistCell", bundle: nil)
                    self.artistTableView.register(cellNib, forCellReuseIdentifier: "ArtistCell")
                    self.artistTableView.delegate = self
                    self.artistTableView.dataSource = self
                }
            
            let url = NSURL(string: (cButton.session?.sessionMedia.first!)!)
        
            self.player?.setUrl(url as! URL)
        self.player?.fillMode = "AVLayerVideoGravityResizeAspectFill"
            //self.player?.fillMode = "resizeAspectFill"
        //self.player?.playerView = self.playerContainerView
            //if cButton.center.y >= self.sessionViewsLabel2.center.y/*self.sessionInfoView.bounds.maxY*/{
                self.player?.playFromBeginning()
               // currentButtonFunc().setIsDiplayedButton(isDisplayedButton: true)
            //self.sessInfoView.isHidden = false
                swiftTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(SessionFeedViewController.updateCounter), userInfo: nil, repeats: true)
                //print("ct \(player?.currentTime)")
           
            //}else{
                //currentButtonFunc().setIsDiplayedButton(isDisplayedButton: false)
            
               // self.player?.stop()
            //cButton.setIsDiplayedButton(isDisplayedButton: false)
           // }
        /*}else{
            //self.sessInfoView.isHidden = true
            self.player?.stop()
            self.player?.playerView.isHidden = true
            sessionNameLabel.text = " "
            
            sessionViewCountLabel.text = " "
        }*/
        DispatchQueue.main.async{
            self.artistTableView.reloadData()
            
            
        }

    }
    var swiftTimer = Timer()
    //problem is caused by current button moving before update count occurs
    func playerDidFinishPlaying(note: NSNotification){
        print("pf")
        currentButtonFunc().sessionViews! += 1
        viewArray[sessionArray.index(of: currentButtonFunc().session!)!] += 1
    }
    
    var count = Int()
    func updateCounter() {
        if count == 30{
            currentButtonFunc().sessionViews! += 1
            viewArray[sessionArray.index(of: currentButtonFunc().session!)!] += 1
            swiftTimer.invalidate()
            count = 0
        }
        count += 1
        //countingLabel.text = String(SwiftCounter++)
    }
    
    @IBOutlet weak var displayLine: UIView!
    
    func currentButtonFunc()->ONBGuitarButton{
        
        if self.viewPins.count != 0 {
            var closest = self.viewPins[0]
            for i in viewPins{
                if(fabs((i as! ONBGuitarButton).center.y - CGFloat(kFretY)) < (fabs((closest as! ONBGuitarButton).center.y - CGFloat(kFretY)))){
                    closest = i as! ONBGuitarButton
                
                }
            }
            self.currentButton = (closest as! ONBGuitarButton)
            /*if (currentButton != nil) && currentButton != closest as? ONBGuitarButton{
                currentButton?.setIsDiplayedButton(isDisplayedButton: false)
                self.player?.stop()
            }*/
            print((closest as! ONBGuitarButton).center.y)
            print(self.displayLine.bounds.maxY)
            if(closest as! ONBGuitarButton).center.y >= self.displayLine.center.y - 50 {
                (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: true)
            }else{
                (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
                self.player?.stop()
            }
       
            return (closest as! ONBGuitarButton)
            
        }else{
            let temp = ONBGuitarButton()
            return temp
        }
       
    }
    var touchesBeganBool = Bool()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBeganBool = true
        let t = touches.first
        //print(t)
        firstTouch = (t?.location(in: self.view))!
        //print(firstTouch)
        firstTouch.y /= 15
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.player?.stop()
        let t = touches.first
        var nextTouch = t?.location(in: self.view)
        nextTouch?.y /= 15
        if sessionArray.count != 0{
        for i in viewPins{
            (i as! ONBGuitarButton).offsetYPosition(offset: (nextTouch?.y)! - firstTouch.y)
            scrollOffset += (nextTouch?.y)! - firstTouch.y
            //(i as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
            
            
                
            }
            
            

            
            
        
        firstTouch = nextTouch!
            
        /*if ((currentButton?.center.y)! >= self.sessionInfoView.bounds.maxY){
                currentButton?.setIsDiplayedButton(isDisplayedButton: true)
            
        }else{
            currentButton?.setIsDiplayedButton(isDisplayedButton: false)
            }*/
           // if(currentButtonFunc().center.y >= self.sessionInfoView.bounds.maxY){
            //currentButtonFunc().setIsDiplayedButton(isDisplayedButton: true)
            //displaySessionInfo()
       // }
            
        //displaySessionInfo()
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBeganBool = false
        for i in viewPins{
            //(i as! ONBGuitarButton).offsetYPosition(offset: (nextTouch?.y)! - firstTouch.y)
            //scrollOffset += (nextTouch?.y)! - firstTouch.y
            (i as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
            
            
            
        }

        if currentButtonFunc().isDisplayed == true{
            displaySessionInfo()
        }else{
            player?.stop()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    /*class DropDownView: YNDropDownView {
        // override method to call open & close
        override func dropDownViewOpened() {
            print("dropDownViewOpened")
        }
        
        override func dropDownViewClosed() {
            print("dropDownViewClosed")
        }
    }*/


}

