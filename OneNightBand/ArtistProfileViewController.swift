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

class ArtistProfileViewController: UIViewController, UINavigationControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var vidCollectionView: UICollectionView!
    @IBOutlet weak var picCollectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var ref = FIRDatabase.database().reference()
    var dictionaryOfInstruments: [NSDictionary] = [NSDictionary]()
    var tags = [Tag]()
    var artistUID: String!
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
                
        self.bioTextView.delegate = self
        
        
        let userID = FIRAuth.auth()?.currentUser?.uid
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
                self.profilePicture.loadImageUsingCacheWithUrlString(profileImageUrl as! String)
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("users").child(artistUID!).child("instruments").observeSingleEvent(of: .value, with: { (snapshot) in
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
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        //navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        //if FIRAuth.auth()?.currentUser?.uid == nil {
          //  perform(#selector(handleLogout), with: nil, afterDelay: 0)
       // }
        
        //set image picker delegate and then set profile pic constraints
        
        profilePicture.layer.borderWidth = 2
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.width/2
        profilePicture.clipsToBounds = true
        
        
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

        
}
