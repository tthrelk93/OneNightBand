//
//  ArtistProfileViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/26/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ArtistProfileViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    var ref = FIRDatabase.database().reference()
    var dictionaryOfInstruments: [NSDictionary] = [NSDictionary]()
    var tags = [Tag]()
    var artistUID: String!
    var youtubeArray = [NSURL]()
    var sizingCell: VideoCollectionViewCell?
    var tempLink: NSURL?
    
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
            
            if let profileImageUrl = value?["profileImageUrl"] {
                self.profilePicture.loadImageUsingCacheWithUrlString((profileImageUrl as! [String]).first!)
            }
            
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
            self.ref.child("users").child(self.artistUID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        
                        self.youtubeArray.append(NSURL(string: snap.value as! String)!)
                        self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.videoCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.videoCollectionView.backgroundColor = UIColor.clear
                        self.videoCollectionView.dataSource = self
                        self.videoCollectionView.delegate = self
                    }
                }
            })

            
        })
        
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.clipsToBounds = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.youtubeArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
        
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        
    }
    func configureCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath) {

        cell.videoURL = self.tempLink
        cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
        
            
        
    }

    

    
}
