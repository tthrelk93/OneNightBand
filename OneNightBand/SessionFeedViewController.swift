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




class SessionFeedViewController: UIViewController, UIGestureRecognizerDelegate,UINavigationControllerDelegate,  FeedDismissalDelegate {
    
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
    var sessionsInDatabase = [Session]()
    var sessFeedKeyArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let profileButton = UIBarButtonItem(title: "profile", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SessionFeedViewController.backToNav)) // navigationItem.leftBarButtonItem
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
    
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender _: AnyObject?) {
        if let vc = segue.destination as? FeedDismissable
        {
            vc.feedDismissalDelegate = self
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
    
    func displaySessionInfo(){
        
        
        let cButton = currentButtonFunc()
        if cButton.isDisplayed == true{
            self.player?.playerView.isHidden = false
            
        let tempLabel = (cButton.session?.sessionName)!
        sessionNameLabel.text = tempLabel
        
        sessionViewCountLabel.text = "Views: \(String(describing: cButton.sessionViews!))"
        
        let url = NSURL(string: (cButton.session?.sessionMedia.first!)!)
            
          //  let item = AVPlayerItem(asset: asset)
        //let videoUrl = self.currentVideoURL
        self.player?.setUrl(url as! URL)
        self.player?.fillMode = "AVLayerVideoGravityResizeAspectFill"
        //self.player?.playerView = self.playerContainerView
        if (cButton.center.y) >= self.sessionInfoView.bounds.maxY{
            self.player?.playFromBeginning()
            
            swiftTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(SessionFeedViewController.updateCounter), userInfo: nil, repeats: true)
                //print("ct \(player?.currentTime)")
           
        }else{
            
            self.player?.stop()
            //cButton.setIsDiplayedButton(isDisplayedButton: false)
        }
        }else{
            self.player?.stop()
            self.player?.playerView.isHidden = true
            sessionNameLabel.text = " "
            
            sessionViewCountLabel.text = " "
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
    
    
    func currentButtonFunc()->ONBGuitarButton{
        
        if self.viewPins.count != 0 {
            var closest = self.viewPins[0]
            for i in viewPins{
                if(fabs((i as! ONBGuitarButton).center.y - CGFloat(kFretY)) < (fabs((closest as! ONBGuitarButton).center.y - CGFloat(kFretY)))){
                    closest = i as! ONBGuitarButton
                
                }
            }
            if (currentButton != nil) && currentButton != closest as? ONBGuitarButton{
                currentButton?.setIsDiplayedButton(isDisplayedButton: false)
            }
        
            if(closest as! ONBGuitarButton).center.y >= self.sessionInfoView.bounds.maxY{
                (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: true)
            }else{
                (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
                self.player?.stop()
            }
        /*if (closest as! ONBGuitarButton).center.y >= self.sessionInfoView.bounds.maxY{
            (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: true)
            
        }else{
            (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
        }*/
       
                //self.currentButton?.setIsDiplayedButton(isDisplayedButton: false) tempButton.setIsDiplayedButton(isDisplayedButton: true)
        //tempButton.setIsDiplayedButton(isDisplayedButton: false)
        /*if (tempButton.center.y >= self.sessionInfoView.bounds.maxY){
            tempButton.setIsDiplayedButton(isDisplayedButton: true)
            
        }else{
            tempButton.setIsDiplayedButton(isDisplayedButton: false)
        }*/

            self.currentButton = (closest as! ONBGuitarButton)
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
        
        let t = touches.first
        var nextTouch = t?.location(in: self.view)
        nextTouch?.y /= 15
        if sessionArray.count != 0{
        for i in viewPins{
            (i as! ONBGuitarButton).offsetYPosition(offset: (nextTouch?.y)! - firstTouch.y)
            scrollOffset += (nextTouch?.y)! - firstTouch.y
            
            
                
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
        if currentButtonFunc().isDisplayed == true{
            displaySessionInfo()
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

}
