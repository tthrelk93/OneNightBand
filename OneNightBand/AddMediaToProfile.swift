//
//  AddMediaToProfile.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 12/1/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import Firebase
import Soundcloud

class AddMediaToSession: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, Dismissable{
    
    var soundCloudIsConnected: Bool!
   // var curIndexPath: [IndexPath]!
    
    
    @IBOutlet weak var soundCloudIDTextField: UITextField!
    
    @IBAction func connectDeletePressed(_ sender: AnyObject) {
        if (soundCloudIDTextField.text?.isEmpty)!{
            print("empty field") //then print error popup
        }else{
            if connectDeleteSoundcloudButton.titleLabel?.text == "Connect"{
                soundCloudID = soundCloudIDTextField.text!
                soundCloudIDTextField.endEditing(true)
                soundCloudIDTextField.placeholder = soundCloudID
                connectDeleteSoundcloudButton.setTitle("Remove", for: .normal)
                shadeView.isHidden = false
            }else{
                soundCloudID = ""
                soundCloudIDTextField.text = ""
                soundCloudIDTextField.placeholder = "Paste SoundCloud ID"
                connectDeleteSoundcloudButton.setTitle("Connect", for: .normal)
                shadeView.isHidden = true
            }
        }
        
    }
    var curCount = Int()
    
    let picker = UIImagePickerController()
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)

    }
    @IBOutlet weak var youtubeTitleTextField: UITextField!
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    @IBOutlet weak var soundcloudCollectionView: UICollectionView!
    @IBOutlet weak var connectDeleteSoundcloudButton: UIButton!
    @IBOutlet weak var shadeView: UIView!
    @IBAction func addYoutubeVideoButtonPressed(_ sender: AnyObject) {
        
        if youtubeLinkField == nil || youtubeTitleTextField == nil{
            print("youtube field empty") //display error popup
        }else{
            
            self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
            self.currentYoutubeTitle = self.youtubeTitleTextField.text!
            
        }
        ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                if snapshots.count == 0{
                    self.YoutubeArray.append(self.youtubeTitleTextField.text!)
                    self.youtubeLinkArray.append(NSURL(string: self.youtubeLinkField.text!)!)
                    self.tempLink = NSURL(string: self.youtubeLinkField.text!)
                    self.tempTitle = self.youtubeTitleTextField.text!
                    //self.YoutubeArray.append(snap.value as! String)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                    self.curCount += 1

                }else{
                    ///clean shit up all i need to do is create a new cell if the collection view is empty
                    self.tempTitle = self.currentYoutubeTitle!
                    self.tempLink = self.currentYoutubeLink
                    self.currentCollectID = "youtube"
                    self.YoutubeArray.append(self.currentYoutubeTitle!)
                    self.youtubeLinkArray.append(self.currentYoutubeLink)
                    self.curCount += 1

                    
                    self.youtubeCollectionView.insertItems(at: [self.youtubeCollectionView.indexPath(for: self.youtubeCollectionView.visibleCells.first!)!])
                   
                }
                
                
            }
            
                
                
                
                //self.youtubeCollectionView.insertItems(at: self.curIndexPath
            /*let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
            self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
            
            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
            self.youtubeCollectionView.backgroundColor = UIColor.clear
            self.youtubeCollectionView.dataSource = self
            self.youtubeCollectionView.delegate = self*/

           // self.YoutubeArray.append(self.currentYoutubeTitle!)
            //self.youtubeLinkArray.append(self.currentYoutubeLink)
                
            //self.currentCollectID = "youtube"
            //self.YoutubeArray.removeAll()
                /*for snap in snapshots{
                    self.YoutubeArray.append(snap.value as! String)
                    
                }
                YoutubeArray.append([currentYoutubeTitle!:currentYoutubeLink])*/
            
            
        })
        DispatchQueue.main.async {
            self.youtubeCollectionView.reloadData()
        }

        self.youtubeTitleTextField.text = ""
        self.youtubeLinkField.text = ""

    }
    var mediaArray: [[String:Any]]?
    let userID = FIRAuth.auth()?.currentUser?.uid
    //var newestYoutubeVid: String?
    
    var currentYoutubeTitle: String?
    var soundCloudSongArray = [String]()

    @IBAction func saveTouched(_ sender: AnyObject) {
        
        if (soundCloudID == "" && currentYoutubeLink == nil){
           print("soundcloud empty")
            
        }
            print(soundCloudID)
            let recipient = self.ref.child("users").child(userID!).child("media")
            var values = Dictionary<String, Any>()
            var values2 = Dictionary<String, Any>()
            
            values["soundcloud"] = soundCloudID
            ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
                
                /*if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    for snap in snapshots{
                        self.YoutubeArray.append(snap.value as! String)
                 
                        
                    }
                }
                */
                //self.YoutubeArray.append(self.currentYoutubeLink)
                if self.currentYoutubeLink != nil{
                    values2[self.currentYoutubeTitle!] = String(describing: self.currentYoutubeLink!)
                    recipient.child("youtube").updateChildValues(values2, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err)
                            return
                        }
                    })
                }
                 if self.soundCloudID != ""{
                    recipient.updateChildValues(values, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err)
                            return
                        }
                    })
                }
            
            
            //**the only problem is reloading picture collection view on profile after adding new image
            
            if self.newImage.image != nil{
                let imageName = NSUUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
                if let uploadData = UIImageJPEGRepresentation(self.newImage.image!, 0.1) {
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print(error)
                            return
                        }
                    
                
                self.ref.child("users").child(self.userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                    
                    for snap in snapshots{
                        self.picArray.append(snap.value as! String)
                    }
                    if self.picArray.count == 0{
                        self.picArray.append(snapshot.value as! String)
                    }
                    
                    self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
               
                    var values3 = Dictionary<String, Any>()
                    print(self.picArray)
                    values3["profileImageUrl"] = self.picArray
                    self.ref.child("users").child(self.userID!).updateChildValues(values3, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err)
                            return
                        }
                    })
                    
                })
                    
                    })
                
                }
                
                
                
            }
                })
            
        
       _ = self.navigationController?.popViewController(animated: true)

        
    }
    var picArray = [String]()
    var currentPicker: String?
    @IBOutlet weak var youtubeLinkField: UITextField!
    @IBOutlet weak var videoTitleTextField: UITextField!
    @IBOutlet weak var soundCloudCollectionView: UICollectionView!
    weak var dismissalDelegate: DismissalDelegate?
    var ref = FIRDatabase.database().reference()
    var soundCloudID = ""

    var sizingCell = VideoCollectionViewCell()
    var currentCollectID = "youtube"
    var currentYoutubeLink: NSURL!
    var youtubeLinkArray = [NSURL]()
    
    var tempLink: NSURL?
    var tempTitle: String?
    var YoutubeArray = [String]()
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        imagePicker.delegate = self
        picker.delegate = self
        curCount = 0
        Soundcloud.clientIdentifier = "com.tthrelk.ios"
        Soundcloud.clientSecret  = "YOUR_CLIENT_SECRET"
        Soundcloud.redirectURI = "YOUR_REDIRECT_URI"
        ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                self.currentCollectID = "youtube"
                
                for snap in snapshots{
                    self.YoutubeArray.append(snap.key as String)
                    self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                    self.tempLink = NSURL(string: (snap.value as? String)!)
                    self.tempTitle = snap.key
                    //self.YoutubeArray.append(snap.value as! String)
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                   self.curCount += 1
                    

                }
                

                
            }
                       })

        
        
        
        if (soundCloudIDTextField.text?.isEmpty)!{
            connectDeleteSoundcloudButton.setTitle("Connect", for: .normal)
            shadeView.isHidden = true
        }else{
            connectDeleteSoundcloudButton.setTitle("Remove", for: .normal)
            shadeView.isHidden = false
            
        }


        
    }
    
    
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.currentCollectID == "youtube"{
            return curCount
        }else{
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
        
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        
        return cell
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
    func configureCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        print(self.currentCollectID)
        if(self.currentCollectID == "youtube"){
            //cell. = self.currentYoutubeTitle
            print(self.tempLink)
            cell.videoID = self.tempTitle
            cell.videoURL = self.tempLink
            cell.youtubePlayerView.loadVideoURL(videoURL: self.tempLink!)
            
            
        }
        }
    
    @IBOutlet weak var newImage: UIImageView!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if currentPicker == "photo"{
        
            var selectedImageFromPicker: UIImage?
            
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
                selectedImageFromPicker = originalImage
            }
        
            if let selectedImage = selectedImageFromPicker {
                
                self.newImage.image = selectedImage
                }
        
            self.dismiss(animated: true, completion: nil)
            
        
        }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    }


    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
        
}
