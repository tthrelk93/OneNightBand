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





class SessionMakerViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, GetSessionIDDelegate{
    
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
    var sizingCell2: VideoCollectionViewCell?
    
    @IBOutlet weak var sessionVidCollectionView: UICollectionView!
    
    @IBOutlet weak var chatButton: UIButton!
    
    func getSessID()->String{
        return sessionID!
    }
    override func viewDidLoad(){
        super.viewDidLoad()
        let userID = FIRAuth.auth()?.currentUser?.uid
        editSessionButton.setTitle("Add and Remove Media", for: .normal)
        editSessionButton.titleLabel?.numberOfLines = 3
        editSessionButton.setTitleColor(UIColor.darkGray, for: .normal)
        editSessionButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightLight)
        editSessionButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        AddMusiciansButton.setTitle("Find Musicians", for: .normal)
        AddMusiciansButton.titleLabel?.numberOfLines = 2
        AddMusiciansButton.setTitleColor(UIColor.darkGray, for: .normal)
        AddMusiciansButton.titleLabel?.font = UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightLight)
        AddMusiciansButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        chatButton.setTitle("Session Chat", for: .normal)
        chatButton.titleLabel?.numberOfLines = 2
        chatButton.setTitleColor(UIColor.darkGray, for: .normal)
        chatButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightLight)
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
                            
                            for val in tempSess.sessionMedia{
                                self.vidArray.append(NSURL(string: val)!)
                                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                self.sessionVidCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                
                                self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                self.sessionVidCollectionView.backgroundColor = UIColor.clear
                                self.sessionVidCollectionView.delegate = self
                                self.sessionVidCollectionView.dataSource = self

                            }
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
    
    
    var vidArray = [NSURL]()
    var videoCollectEmpty: Bool?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if vidArray.count != 0{
            self.videoCollectEmpty = false
            return self.vidArray.count
            
        }else{
            self.videoCollectEmpty = true
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            configureVidCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.indexPath = indexPath
            
            //self.curIndexPath.append(indexPath)
            
            return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func configureVidCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        if self.videoCollectEmpty == true{
            //cell.layer.borderColor = UIColor.white.cgColor
            //cell.layer.borderWidth = 2
            print("rmpty")
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
            cell.videoURL = self.vidArray[indexPath.row]
            cell.youtubePlayerView.loadVideoURL(self.vidArray[indexPath.row] as URL)
            cell.removeVideoButton.isHidden = true
            cell.noVideosLabel.isHidden = true
        }
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
