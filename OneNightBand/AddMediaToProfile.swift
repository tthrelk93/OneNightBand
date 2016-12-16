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

protocol RemoveVideoDelegate : class
{
    func removeVideo(removalVid: NSURL)
    
}
protocol RemoveVideoData : class
{
    weak var removeVideoDelegate : RemoveVideoDelegate? { get set }
}


class AddMediaToSession: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource,LoadCollectionViewData, RemoveVideoDelegate{
    
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
    
    
    
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    @IBOutlet weak var soundcloudCollectionView: UICollectionView!
    @IBOutlet weak var connectDeleteSoundcloudButton: UIButton!
    @IBOutlet weak var shadeView: UIView!
    @IBAction func addYoutubeVideoButtonPressed(_ sender: AnyObject) {
        
        if youtubeLinkField == nil{
            print("youtube field empty") //display error popup
        }else{
            
            self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
           
            
        }
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
            var tempArray1 = [String]()
            for snap in snapshots{
                tempArray1.append(snap.key)
            }
            if tempArray1.contains("media"){
                for snap in snapshots{
                    if snap.key == "media"{
                        let mediaKids = snap.children.allObjects as! [FIRDataSnapshot]
                        var tempArray = [String]()
                        for mediaKid in mediaKids{
                            tempArray.append(mediaKid.key as! String)
                        }
                        if tempArray.contains("youtube"){
                            self.tempLink = self.currentYoutubeLink
                            self.currentCollectID = "youtube"
                            self.youtubeLinkArray.append(self.currentYoutubeLink)
                            self.curCount += 1
                            self.youtubeCollectionView.insertItems(at: [self.youtubeCollectionView.indexPath(for: self.youtubeCollectionView.visibleCells.first!)!])
                            break
                        }else{
                            self.youtubeLinkArray.append(NSURL(string: self.youtubeLinkField.text!)!)
                            self.tempLink = NSURL(string: self.youtubeLinkField.text!)
                        
                            //self.YoutubeArray.append(snap.value as! String)
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.youtubeCollectionView.backgroundColor = UIColor.clear
                            self.youtubeCollectionView.dataSource = self
                            self.youtubeCollectionView.delegate = self
                            self.curCount += 1
                            break
                        }
                    }
                }
            }//else if it doesnt contain media 
            else{
                self.youtubeLinkArray.append(NSURL(string: self.youtubeLinkField.text!)!)
                self.tempLink = NSURL(string: self.youtubeLinkField.text!)
                
                //self.YoutubeArray.append(snap.value as! String)
                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                
                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                self.youtubeCollectionView.backgroundColor = UIColor.clear
                self.youtubeCollectionView.dataSource = self
                self.youtubeCollectionView.delegate = self
                self.curCount += 1

            }
        })

        /*if youtubeLinkArray.count == 0{
         
        }
        ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                if snapshots.count == 0{
                    
                    self.youtubeLinkArray.append(NSURL(string: self.youtubeLinkField.text!)!)
                    self.tempLink = NSURL(string: self.youtubeLinkField.text!)
                   
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
                   
                    self.tempLink = self.currentYoutubeLink
                    self.currentCollectID = "youtube"
                    
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
            
            
        })*/
        DispatchQueue.main.async {
          self.youtubeCollectionView.reloadData()
            
        }

        
        self.youtubeLinkField.text = ""

    }
    var mediaArray: [[String:Any]]?
    let userID = FIRAuth.auth()?.currentUser?.uid
    //var newestYoutubeVid: String?
    
    var currentYoutubeTitle: String?
    var soundCloudSongArray = [String]()
    var youtubeDataArray = [String]()
    @IBAction func saveTouched(_ sender: AnyObject) {
        loadDataDelegate?.loadCollectView()
        if (soundCloudID == "" && currentYoutubeLink == nil){
           print("field empty")
            
        }
        
            let recipient = self.ref.child("users").child(userID!).child("media")
            var values = Dictionary<String, Any>()
            var values2 = Dictionary<String, Any>()
            
            values["soundcloud"] = soundCloudID
            ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
                let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                for snap in snapshots{
                    self.youtubeDataArray.append(snap.value as! String)
                }
                
                
                
                /*if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    for snap in snapshots{
                        self.YoutubeArray.append(snap.value as! String)
                 
                        
                    }
                }
                */
                //self.YoutubeArray.append(self.currentYoutubeLink)
                if self.currentYoutubeLink != nil{
                    self.youtubeDataArray.append(String(describing: self.currentYoutubeLink!))
                    values2["youtube"] = self.youtubeDataArray

                    recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
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
    
    
    //**I'm removing the first element everytime rather than at the correct index path. Also might be adding to begginning but appending to array thus creating data inconsistency
    internal func removeVideo(removalVid: NSURL) {
        self.currentCollectID = "youtube"
        
        
        var tempIndex = 0
        for vid in youtubeLinkArray{
            if removalVid == vid{
                break
            }else{
                tempIndex += 1
            }
        }
        self.youtubeLinkArray.remove(at: tempIndex)
        self.curCount -= 1
        
        self.youtubeCollectionView.deleteItems(at: [self.youtubeCollectionView.indexPath(for: self.youtubeCollectionView.visibleCells[tempIndex])!])
        var values4 = Dictionary<String, Any>()
        self.youtubeDataArray.removeAll()
        for val in self.youtubeLinkArray{
            self.youtubeDataArray.append(String(describing: val))
        }
        values4["youtube"] = self.youtubeDataArray
        ref.child("users").child(userID!).child("media").updateChildValues(values4)
        
        
        //DispatchQueue.main.async {
           // self.youtubeCollectionView.reloadData()
            
        //}
    }
    
    var picArray = [String]()
    var currentPicker: String?
    @IBOutlet weak var youtubeLinkField: UITextField!
    
    @IBOutlet weak var soundCloudCollectionView: UICollectionView!
    weak var dismissalDelegate: DismissalDelegate?
    var ref = FIRDatabase.database().reference()
    var soundCloudID = ""

    var sizingCell = VideoCollectionViewCell()
    var currentCollectID = "youtube"
    var currentYoutubeLink: NSURL!
    var youtubeLinkArray = [NSURL]()
    
    var tempLink: NSURL?
   
    
    
    weak var loadDataDelegate : LoadCollectionViewDelegate?
    
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
                    
                    self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                    self.tempLink = NSURL(string: (snap.value as? String)!)
                    
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
            
            
            cell.removeVideoDelegate = self
            cell.videoURL = self.youtubeLinkArray[indexPath.row]
            cell.videoIndex = indexPath.row
            cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeLinkArray[indexPath.row])
            
            
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
