//
//  ArtistProfileViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/26/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
//import Firebase
import FirebaseAuth
import FirebaseDatabase


class ArtistProfileViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var ref = FIRDatabase.database().reference()
    var dictionaryOfInstruments: [NSDictionary] = [NSDictionary]()
    var tags = [Tag]()
    var artistUID: String!
    var youtubeArray = [NSURL]()
    var sizingCell2: VideoCollectionViewCell?
    var sizingCell: PictureCollectionViewCell?
    var tempLink: NSURL?
    var picArray = [UIImage]()
    var group = DispatchGroup()
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
                
        self.bioTextView.delegate = self
        
        
        _ = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(artistUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            //print(snapshot.value as? NSDictionary)
            let value = snapshot.value as? NSDictionary
            self.bioTextView.text = value?["bio"] as! String
            self.navigationItem.title = (value?["name"] as! String)
            
            //self.profilePicture.image?.accessibilityIdentifier = value?["profileImageUrl"] as! String
            //let user = users[(indexPath as NSIndexPath).row]
            //cell.textLabel?.text = user.name
            //cell.detailTextLabel?.text = user.email
            
            /*if let profileImageUrl = value?["profileImageUrl"] {
                self.profilePicture.loadImageUsingCacheWithUrlString((profileImageUrl as! [String]).first!)
            }*/
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("users").child(artistUID!).child("instruments").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    let tag = Tag()
                    tag.name = (snap.key)
                    tag.selected = true
                    self.tags.append(tag)
                }
            }
            

            
        })
        ref.child("users").child(self.artistUID).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            self.group.enter()
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                self.currentCollect = "youtube"
                
                for snap in snapshots{
                    
                    self.youtubeArray.append(NSURL(string: snap.value as! String)!)
                    
                    
                }
                if self.youtubeArray.count == 0{
                    self.currentCollect = "vid"
                    self.videoCollectEmpty = true
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.videoCollectionView.backgroundColor = UIColor.clear
                    self.videoCollectionView.dataSource = self
                    self.videoCollectionView.delegate = self
                    
                }else{
                    self.videoCollectEmpty = false
                    for snap in snapshots{
                        self.currentCollect = "vid"
                        self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.videoCollectionView.backgroundColor = UIColor.clear
                        self.videoCollectionView.dataSource = self
                        self.videoCollectionView.delegate = self
                        //self.curCount += 1
                        
                    }
                }
            }
            
            
            
            
            
            self.ref.child("users").child(self.artistUID!).child("activeSessions").observeSingleEvent(of: .value, with: {(snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    //self.sessionsPlayed.text = String(snapshots.count)
                    
                }
            })
            
            self.group.leave()
            
            
            self.group.enter()
            self.ref.child("users").child(self.artistUID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                
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
                    self.pictureCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                    self.pictureCollectionView.backgroundColor = UIColor.clear
                    self.pictureCollectionView.dataSource = self
                    self.pictureCollectionView.delegate = self
                    
                }
            })
            self.group.leave()
        })
    

    
        
        
    }
    
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
            cell.youtubePlayerView.loadVideoURL(self.youtubeArray[indexPath.row] as URL)
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
    

    

    
}
