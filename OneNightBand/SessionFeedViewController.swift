//
//  SessionFeedViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/3/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import UIKit
import Firebase


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
        
        //self.currentButton = currentButtonFunc()
        
        
        self.player?.view.frame = self.sessionImageView.frame
        //self.playerContainerView.viewController()?.addChildViewController(player!)
        //self.playerContainerView.viewController().
        //self.player?.delegate = self
        
        switch UIScreen.main.bounds.width{
        case 320:
            self.player?.view.frame = CGRect(x: 35,y:50,width:250,height:130)
            
        case 375:
            self.player?.view.frame = CGRect(x: 40,y:85,width:300,height:200)
            
            
        case 414:
            self.player?.view.frame = CGRect(x: 33,y:100,width:350,height:250)
            
        default:
            self.player?.view.frame = CGRect(x: 60,y:140,width:350,height:250)
            
            
            
        }
        

        
        
        self.sessionInfoView.autoresizesSubviews = true
        
        self.addChildViewController(self.player!)
        sessionInfoView.addSubview((self.player?.view)!)
       // self.sessionInfoView.addSubview((controller?.view)!)
        
        }
    func addNewSession(){
        performSegue(withIdentifier: "FeedToUpload", sender: self)
    }
    func backToNav(){
        performSegue(withIdentifier: "BackToMainNav", sender: self)
    }
    var sessionsInDatabase = [Session]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(SessionFeedViewController.backToNav))
        navigationItem.leftBarButtonItem = backButton
        let uploadButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(SessionFeedViewController.addNewSession))
        navigationItem.rightBarButtonItem = uploadButton
        
        
        
        self.ref.child("sessionFeed").observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.childrenCount != 0{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshots{
                    let tempSess = Session()
                    let dictionary = snap.value as? [String: AnyObject]
                    
                 
                    tempSess.setValuesForKeys(dictionary!)
                    self.sessionArray.append(tempSess)
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
                
                
                
                self.view.addSubview(button)
                self.viewPins.add(button)
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.scrollToPin))
                
                tap.numberOfTapsRequired = 1
                button.addGestureRecognizer(tap)
                button.isUserInteractionEnabled = true
                button.session = self.sessionArray[i]
                    
            
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
    func displaySessionInfo(){
        
        
        let cButton = currentButtonFunc()
    
        let tempLabel = (cButton.session?.sessionName)!
        sessionNameLabel.text = "Session Name: \(tempLabel)"
        
        sessionViewCountLabel.text = "Views: 346"//String(describing: currentButtonSess.sessionViews)  need to add views to Session in database
        //sessionImageView.loadImageUsingCacheWithUrlString((cButton.session?.sessionPictureURL)!)
        
        let url = NSURL(string: (cButton.session?.sessionMedia.first!)!)
        
        //let videoUrl = self.currentVideoURL
        self.player?.setUrl(url as! URL)
        self.player?.fillMode = "AVLayerVideoGravityResizeAspectFill"
        //self.player?.playerView = self.playerContainerView
        if (cButton.center.y) >= self.sessionInfoView.bounds.maxY{
            self.player?.playFromBeginning()
        }else{
            self.player?.stop()
            //cButton.setIsDiplayedButton(isDisplayedButton: false)
        }

                
     


    }
    
    func currentButtonFunc()->ONBGuitarButton{
        var closest = self.viewPins[0]
        for i in viewPins{
            if(fabs((i as! ONBGuitarButton).center.y - CGFloat(kFretY)) < (fabs((closest as! ONBGuitarButton).center.y - CGFloat(kFretY)))){
                closest = i
                
            }
        }
        if (currentButton != nil) && currentButton != closest as? ONBGuitarButton{
            currentButton?.setIsDiplayedButton(isDisplayedButton: false)
        }
        
        if(closest as! ONBGuitarButton).center.y >= self.sessionInfoView.bounds.maxY{
            (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: true)
        }else{
            (closest as! ONBGuitarButton).setIsDiplayedButton(isDisplayedButton: false)
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
