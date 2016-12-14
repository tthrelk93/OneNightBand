//
//  SessionMakerViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/8/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import Firebase
import UIKit




protocol GetSessionIDDelegate : class
{
    func getSessID()->String
    
}
protocol SessionIDDest : class
{
    weak var getSessionID : GetSessionIDDelegate? { get set }
}





class SessionMakerViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, GetSessionIDDelegate{
    
    var sessionID: String?
    
    @IBOutlet weak var sessionImageView: UIImageView!
    @IBOutlet weak var addSessionPicButton: UIButton!
    @IBOutlet weak var AddMusiciansButton: UIButton!
    @IBOutlet weak var sessionArtistsTableView: UITableView!
    @IBOutlet weak var sessionInfoTextView: UITextView!
    @IBOutlet weak var editSessionInfoButton: UIButton!
    @IBOutlet weak var removeArtistButton: UIButton!
    
    @IBOutlet weak var editSessionButton: UIButton!
    
    @IBOutlet weak var uploadSessionToFeed: UIButton!
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "SessionToArtistFinder"{
            if let vc = segue.destination as? ArtistFinderViewController
            {
                vc.thisSession = sessionID
                vc.thisSessionObject = thisSession
                
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
    }

    @IBAction func chatPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "SessionToChat", sender: self)
    }
    @IBOutlet weak var chatViewContainerView: UIView!
    
    @IBAction func addMusicianPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "SessionToArtistFinder", sender: self)
    }
    var ref = FIRDatabase.database().reference()
    var sessionIDArray = [String]()
    var thisSession = Session()
    var sessionChat = ChatViewController()
    
    
    @IBOutlet weak var chatButton: UIButton!
    
    func getSessID()->String{
        return sessionID!
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        let userID = FIRAuth.auth()?.currentUser?.uid
        editSessionButton.setTitle("Edit Session", for: .normal)
        editSessionButton.titleLabel?.numberOfLines = 2
        editSessionButton.setTitleColor(UIColor.darkGray, for: .normal)
        editSessionButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: UIFontWeightLight)
        editSessionButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        AddMusiciansButton.setTitle("Find Musicians", for: .normal)
        AddMusiciansButton.titleLabel?.numberOfLines = 2
        AddMusiciansButton.setTitleColor(UIColor.darkGray, for: .normal)
        AddMusiciansButton.titleLabel?.font = UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightLight)
        AddMusiciansButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        chatButton.setTitle("Session Chat", for: .normal)
        chatButton.titleLabel?.numberOfLines = 2
        chatButton.setTitleColor(UIColor.darkGray, for: .normal)
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0, weight: UIFontWeightLight)
        chatButton.titleLabel?.textAlignment = NSTextAlignment.center

        
        
        
        ref.child("users").child(userID!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    self.sessionIDArray.append((snap.value! as! String))
                }
            }
        print(self.getSessID())
        self.ref.child("sessions").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if (snap.key == self.getSessID()){
                            
                            let dictionary = snap.value as? [String: AnyObject]
                            let tempSess = Session()
                            tempSess.setValuesForKeys(dictionary!)
                            self.thisSession = tempSess
                            
                            self.sessionID = self.thisSession.sessionUID
                            self.sessionInfoTextView?.text = tempSess.sessionBio!
                            self.sessionImageView?.loadImageUsingCacheWithUrlString(tempSess.sessionPictureURL!)
                            self.navigationItem.title = tempSess.sessionName
                            //print(self.thisSession.sessionBio)
                            let cellNib = UINib(nibName: "ArtistCell", bundle: nil)
                            self.sessionArtistsTableView.register(cellNib, forCellReuseIdentifier: "ArtistCell")
                            self.sessionArtistsTableView.delegate = self
                            self.sessionArtistsTableView.dataSource = self
                        }
                    }
            }
            DispatchQueue.main.async{
                self.sessionArtistsTableView.reloadData()
            }

            
            
        
        })
    
    
    })
        self.sessionChat.thisSessionID = self.getSessID()
        //self.view.setNeedsDisplay()
}
 
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        return (self.thisSession.sessionArtists.count)
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
        for value in thisSession.sessionArtists{
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
            
            cell.artistNameLabel.text = tempArtist.name
            cell.artistInstrumentLabel.text = "test"
            cell.artistImageView.loadImageUsingCacheWithUrlString(tempArtist.profileImageUrl.first!)
            cell.artistInstrumentLabel.text = instrumentArray[indexPath.row]
        
            })
        return cell
    }

    
    

}
