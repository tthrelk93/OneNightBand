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
import FirebaseDatabase
import FirebaseAuth
import SwiftOverlays
//import Firebase

protocol RemoveVideoDelegate : class
{
    func removeVideo(removalVid: NSURL, isYoutube: Bool)
    
}
protocol RemoveVideoData : class
{
    weak var removeVideoDelegate : RemoveVideoDelegate? { get set }
}
protocol RemovePicDelegate : class
{
    func removePic(removalPic: UIImage)
    
}
protocol RemovePicData : class
{
    weak var removePicDelegate : RemovePicDelegate? { get set }
}



class AddMediaToSession: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, RemoveVideoDelegate, RemovePicDelegate{
    
    var bandID: String?
    var sessionID: String?
    var curIndexPath = [IndexPath]()
    var curCount = Int()
    
    let picker = UIImagePickerController()
    
    var movieURLFromPicker: NSURL?
    var curCell: VideoCollectionViewCell?
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveMediaToSession"{
        if let vc = segue.destination as? MP3PlayerViewController{
            vc.sessionID = self.sessionID
            vc.BandID = self.bandID
            
            }
        }
            
    }
    
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)

    }
    
    
    @IBAction func chooseVidFromPhoneSelected(_ sender: AnyObject) {
        currentPicker = "vid"
        picker.mediaTypes = ["public.movie"]
        
        present(picker, animated: true, completion: nil)
    }
    var senderView = String()
    @IBOutlet weak var vidFromPhoneCollectionView: UICollectionView!
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    var tempArray1 = [String]()
    var tempArray = [String]()
    var lastIndexPath: IndexPath?
    @IBOutlet weak var shadeView: UIView!
    
    
    @IBAction func addYoutubeVideoButtonPressed(_ sender: AnyObject) {
        if senderView == "main"{
            if youtubeLinkField == nil{
                print("youtube field empty")
            }else{
                self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
                ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
            
                    for snap in snapshots{
                        self.tempArray1.append(snap.key)
                    }
            
                    for snap in snapshots{
                        if snap.key == "media"{
                            let mediaKids = snap.children.allObjects as! [FIRDataSnapshot]
                        
                            for mediaKid in mediaKids{
                                self.tempArray.append(mediaKid.key )
                            }
                        }
                    }
                })
                
                self.tempLink = self.currentYoutubeLink
                self.currentCollectID = "youtube"
                youtubeLinkArray.append(self.currentYoutubeLink)
                print(youtubeLinkArray)
                let insertionIndexPath = IndexPath(row: self.youtubeLinkArray.count - 1, section: 0)
                DispatchQueue.main.async{
                    self.youtubeCollectionView.insertItems(at: [insertionIndexPath])
                            
                }
            }
            self.youtubeLinkField.text = ""
            
        } else{
            if youtubeLinkField == nil{
                print("youtube field empty")
            }else{
                self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
                ref.child("sessions").child(self.sessionID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                    
                    for snap in snapshots{
                        self.tempArray1.append(snap.key)
                    }
                    
                    for snap in snapshots{
                        if snap.key == "sessionMedia"{
                            let mediaKids = snap.children.allObjects as! [FIRDataSnapshot]
                            
                            for mediaKid in mediaKids{
                                self.tempArray.append(mediaKid.key )
                            }
                        }
                    }
                })
                
                self.tempLink = self.currentYoutubeLink
                self.currentCollectID = "youtube"
                youtubeLinkArray.append(self.currentYoutubeLink)
                print(youtubeLinkArray)
                let insertionIndexPath = IndexPath(row: self.youtubeLinkArray.count - 1, section: 0)
                DispatchQueue.main.async{
                    self.youtubeCollectionView.insertItems(at: [insertionIndexPath])
                    
                }
            }
            self.youtubeLinkField.text = ""

        }

    
        }
    
    
    
    var mediaArray: [[String:Any]]?
    let userID = FIRAuth.auth()?.currentUser?.uid
    //var newestYoutubeVid: String?
    
    var currentYoutubeTitle: String?
    var vidFromPhoneArray = [NSURL]()
    var youtubeDataArray = [String]()
    var recentlyAddedVidArray = [String]()
    var recentlyAddedPicArray = [UIImage]()
    var allVidURLs = [String]()
    //uploads appropriate media to database
    @IBAction func saveTouched(_ sender: AnyObject) {
        if senderView == "main"{
            if (vidFromPhoneCollectionView.visibleCells.count == 0 && currentYoutubeLink == nil && needToUpdatePics == false && needToRemove == false){
                let alert = UIAlertController(title: "No new media", message: "It appears that you have not chosen any media to upload.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            }else{
                SwiftOverlays.showBlockingWaitOverlayWithText("Updating Media")
            
                    _ = Dictionary<String, Any>()
                    var values2 = Dictionary<String, Any>()
                    let recipient = self.ref.child("users").child(userID!)
            
            
                        for link in youtubeLinkArray{
                            self.allVidURLs.append(String(describing: link))
                        }
                        //values2["youtube"] = self.youtubeDataArray
                
            
                    if recentlyAddedPhoneVidArray.count != 0{
                        
                        for nsurl in recentlyAddedPhoneVidArray{
                            let videoName = NSUUID().uuidString
                            let storageRef = FIRStorage.storage().reference(withPath: "artist_videos").child("\(videoName).mov")
                            var videoRef = storageRef.fullPath
                            let uploadMetadata = FIRStorageMetadata()
                            uploadMetadata.contentType = "video/quicktime"
                            _ = storageRef.putFile(nsurl as URL, metadata: uploadMetadata){(metadata, error) in
                                if(error != nil){
                                    print("got an error: \(error)")
                                }
                                self.allVidURLs.append(videoRef)
                            }
                        }
                        /*for link in vidFromPhoneArray{
                            self.recentlyAddedVidArray.append(String(describing: link))
                        }*/

                        
                    }
                    else{
                        for link in vidFromPhoneArray{
                            self.allVidURLs.append(String(describing: link))
                        }
                        values2["media"] = self.allVidURLs
                }

        
        
                recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                    if err != nil {
                        print(err!)
                        return
                    }
                })
        }
    


    
            
            if self.needToUpdatePics == true{
                print("profPicArray: \(self.profPicArray)")
                var count = 0
                for pic in profPicArray{
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
                    if let uploadData = UIImageJPEGRepresentation(pic, 0.1) {
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                    self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
                            
                
               
                    var values3 = Dictionary<String, Any>()
                    print(self.picArray)
                    values3["profileImageUrl"] = self.picArray
                    self.ref.child("users").child(self.userID!).updateChildValues(values3, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
                    })
                        })
                }
            }
           
        }
        DispatchQueue.main.async{
            self.handleCancel()
       //self.performSegue(withIdentifier: "AddMediaToMain", sender: self)
        }
        
        }
        //else senderView == session
        else{
            if (vidFromPhoneCollectionView.visibleCells.count == 0 && currentYoutubeLink == nil && needToUpdatePics == false && needToRemove == false){
                let alert = UIAlertController(title: "No new media", message: "It appears that you have not chosen any media to upload.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }else{
                SwiftOverlays.showBlockingWaitOverlayWithText("Updating Media")
                
                _ = Dictionary<String, Any>()
                var values2 = Dictionary<String, Any>()
                let recipient = self.ref.child("sessions").child(self.sessionID!)
                
                
                for link in youtubeLinkArray{
                    self.allVidURLs.append(String(describing: link))
                }
                //values2["youtube"] = self.youtubeDataArray
                
                print(recentlyAddedPhoneVidArray)
                if recentlyAddedPhoneVidArray.count != 0{
                    var count = 1
                    for link in vidFromPhoneArray{
                        self.allVidURLs.append(String(describing: link))
                    }
                    for data in self.addedVidDataArray{
                        let videoName = NSUUID().uuidString
                        let storageRef = FIRStorage.storage().reference().child("session_videos").child("\(videoName).mov")
                        var videoRef = storageRef.fullPath
                        
                        //var downloadLink = storageRef.
                        let uploadMetadata = FIRStorageMetadata()
                        uploadMetadata.contentType = "video/quicktime"

                        _ = storageRef.put(data, metadata: uploadMetadata){(metadata, error) in
                            if(error != nil){
                                print("got an error: \(error)")
                            }
                            print("metaData: \(metadata)")
                            print("metaDataURL: \((metadata?.downloadURL()?.absoluteString)!)")
                            self.allVidURLs.append((metadata?.downloadURL()?.absoluteString)!)
                            print("avs:\(self.allVidURLs)")
                            if count == self.addedVidDataArray.count{
                                //DispatchQueue.main.async{
                                    values2["sessionMedia"] = self.allVidURLs
                                    
                                    print("allVids: \(self.allVidURLs)")
                                    recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                                        if err != nil {
                                            print(err!)
                                            return
                                        }
                                    })
                                //}

                            }
                            count += 1
                        }
                    }
                    
                    
                    //values2["vidsFromPhone"] = self.recentlyAddedVidArray
                }
                else{
                    values2["sessionMedia"] = self.allVidURLs
                    
                    print("allVids: \(self.allVidURLs)")
                    recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
                    })
                    
                }
            }
            
            
            
            
            
            if self.needToUpdatePics == true{
                print("profPicArray: \(self.profPicArray)")
                var count = 0
                for pic in profPicArray{
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("session_images").child("\(imageName).jpg")
                    if let uploadData = UIImageJPEGRepresentation(pic, 0.1) {
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
                            
                            
                            
                            var values3 = Dictionary<String, Any>()
                            print(self.picArray)
                            values3["sessionPictureURL"] = self.picArray
                            self.ref.child("sessions").child(self.sessionID!).updateChildValues(values3, withCompletionBlock: {(err, ref) in
                                if err != nil {
                                    print(err!)
                                    return
                                }
                            })
                        })
                    }
                }
                
            }
            DispatchQueue.main.async{
                 self.handleCancel()
            }
 
        }

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SwiftOverlays.removeAllBlockingOverlays()
    }
    //**I'm removing the first element everytime rather than at the correct index path. Also might be adding to begginning but appending to array thus creating data inconsistency
    var needToUpdatePics = Bool()
    @IBOutlet weak var picCollectionView: UICollectionView!
    var needToRemovePic = Bool()
    internal func removePic(removalPic: UIImage){
        if profPicArray.count == 1{
            let alert = UIAlertController(title: "Too Few Pictures Error", message: "Must have at least one picture at all times.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "okay", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
        self.currentCollectID = "picsFromPhone"
        needToRemovePic = true
        needToUpdatePics = true
        print("removePic")
        for pic in 0...profPicArray.count-1{
            if removalPic == profPicArray[pic]{
                profPicArray.remove(at: pic)
                DispatchQueue.main.async{
                    self.picCollectionView.deleteItems(at: [IndexPath(row: pic, section: 0)])
                    print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                }
                break
            }
        }
        }
        
    }
    
    func handleCancel(){
        /*
        if senderView == "main"{
            self.performSegue(withIdentifier: "AddMediaToMain", sender: self)
        }else{
            performSegue(withIdentifier: "SaveMediaToSession", sender: self)
        }*/
        self.performSegue(withIdentifier: "AddMediaToMain", sender: self)

    }
    
   
    var needToRemove = Bool()
    internal func removeVideo(removalVid: NSURL, isYoutube: Bool) {
        print("inRemove")
        if String(describing: removalVid).contains("yout") || String(describing: removalVid).contains("youtu.be"){
            self.currentCollectID = "youtube"
            self.vidRemovalPressed = true
            needToRemove = true
        
            for vid in 0...youtubeLinkArray.count-1{
                if removalVid == youtubeLinkArray[vid]{
                    youtubeLinkArray.remove(at: vid)
                    DispatchQueue.main.async{
                        self.youtubeCollectionView.deleteItems(at: [IndexPath(row: vid, section: 0)])
                    }
                    break
                
                
                
                }
                }
            }
        else{
            
            self.currentCollectID = "vidFromPhone"
            needToRemove = true
            
            for vid in 0...vidFromPhoneArray.count{
                if removalVid == vidFromPhoneArray[vid]{
                    vidFromPhoneArray.remove(at: vid)
                    DispatchQueue.main.async{
                        self.vidFromPhoneCollectionView.deleteItems(at:[IndexPath(row: vid, section: 0)])
                    }
                    break
                }
            }
        }
        

    }
    
    var picArray = [String]()
    var currentPicker: String?
    @IBOutlet weak var youtubeLinkField: UITextField!
    
    
    weak var dismissalDelegate: DismissalDelegate?
    var ref = FIRDatabase.database().reference()
    

    var sizingCell = VideoCollectionViewCell()
    var sizingCell2 = PictureCollectionViewCell()
    var currentCollectID = "youtube"
    var currentYoutubeLink: NSURL!
    var youtubeLinkArray = [NSURL]()
    
    var tempLink: NSURL?
   
    
    
    
    
    let imagePicker = UIImagePickerController()
    var videoCollectEmpty: Bool?
    var recentlyAddedPhoneVid = [String]()
    var profPicArray = [UIImage]()
    var viewDidAppearBool = false
    //var sessionID = String()
    var addedVidDataArray = [Data]()
    override func viewDidAppear(_ animated: Bool) {
        if senderView == "main"{
        
        self.vidRemovalPressed = false
        if viewDidAppearBool == false{
            recentlyAddedVidArray.removeAll()
            youtubeDataArray.removeAll()
            needToRemove = false
            needToRemovePic = false
            imagePicker.delegate = self
            picker.delegate = self
            curCount = 0
        
            ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            if self.youtubeLinkArray.count == 0{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                
                    for snap in snapshots{
                    
                        self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                    
                    
                    }
                    if self.youtubeLinkArray.count == 0{
                        self.currentCollectID = "youtube"
                        self.videoCollectEmpty = true
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.youtubeCollectionView.backgroundColor = UIColor.clear
                        self.youtubeCollectionView.dataSource = self
                        self.youtubeCollectionView.delegate = self
                    
                    }else{
                        
                        self.videoCollectEmpty = false
                        for snap in snapshots{
                            self.currentCollectID = "youtube"
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
                }
        }
            
            
                self.ref.child("users").child(self.userID!).child("media").child("vidsFromPhone").observeSingleEvent(of: .value, with: { (snapshot) in
                if self.vidFromPhoneArray.count == 0{
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    
                        for snap in snapshots{
                        
                            self.vidFromPhoneArray.append(NSURL(string: (snap.value as? String)!)!)
                        
                        }
                        if self.vidFromPhoneArray.count == 0{
                            self.videoCollectEmpty = true
                        }else{
                            
                            self.videoCollectEmpty = false
                            for snap in snapshots{
                                self.currentCollectID = "vidFromPhone"
                                self.tempLink = NSURL(string: (snap.value as? String)!)
                            print(self.tempLink)
                            //self.YoutubeArray.append(snap.value as! String)
                            
                                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            
                                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                self.vidFromPhoneCollectionView.dataSource = self
                                self.vidFromPhoneCollectionView.delegate = self
                               
                            
                            }
                        }
                    
                    }
                    }
            
                
            
                self.ref.child("users").child(self.userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                if self.profPicArray.count == 0{
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    
                        for snap in snapshots{
                        
                            if let url = NSURL(string: snap.value as! String){
                                if let data = NSData(contentsOf: url as URL){
                                    self.profPicArray.append(UIImage(data: data as Data)!)
                                
                                }
                            
                            }
                        }
                        print("pArray: \(self.profPicArray)")
                        
                        //self.videoCollectEmpty = false
                        for snap in snapshots{
                            self.currentCollectID = "picsFromPhone"
                            self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                            //self.YoutubeArray.append(snap.value as! String)
                        
                            let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                            self.picCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                        
                            self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                            self.picCollectionView.backgroundColor = UIColor.clear
                            self.picCollectionView.dataSource = self
                            self.picCollectionView.delegate = self
                        
                        }
                    }
                    }
                })
            })
            
            
        })
            self.viewDidAppearBool = true
        }
        }else{
            self.vidRemovalPressed = false
            if viewDidAppearBool == false{
                recentlyAddedVidArray.removeAll()
                youtubeDataArray.removeAll()
                needToRemove = false
                needToRemovePic = false
                imagePicker.delegate = self
                picker.delegate = self
                curCount = 0
                
                ref.child("sessions").child(sessionID!).child("sessionMedia").observeSingleEvent(of: .value, with: { (snapshot) in
                    if self.youtubeLinkArray.count == 0{
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            
                            
                            for snap in snapshots{
                                if (snap.value as! String).contains("yout"){
                                    self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                                } else {
                                    self.vidFromPhoneArray.append(NSURL(string: snap.value as! String)!)
                                }
                                
                            }
                        }
                        DispatchQueue.main.async{
                            if self.youtubeLinkArray.count == 0{
                                self.currentCollectID = "youtube"
                                self.videoCollectEmpty = true
                                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                
                                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                self.youtubeCollectionView.backgroundColor = UIColor.clear
                                self.youtubeCollectionView.dataSource = self
                                self.youtubeCollectionView.delegate = self
                                
                            }else{
                                
                                self.videoCollectEmpty = false
                                for vid in self.youtubeLinkArray{
                                    self.currentCollectID = "youtube"
                                    self.tempLink = vid
                                    
                                    //self.YoutubeArray.append(snap.value as! String)
                                    
                                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                    
                                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                                    self.youtubeCollectionView.dataSource = self
                                    self.youtubeCollectionView.delegate = self
                                    self.curCount += 1
                                    
                                }
                                if self.vidFromPhoneArray.count == 0{
                                    self.videoCollectEmpty = true
                                }
                                else{
                                    self.videoCollectEmpty = false
                                    for vid in self.vidFromPhoneArray{
                                        self.currentCollectID = "vidFromPhone"
                                        self.tempLink = vid
                                        print(self.tempLink)
                                        //self.YoutubeArray.append(snap.value as! String)
                                    
                                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                    
                                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                        self.vidFromPhoneCollectionView.dataSource = self
                                        self.vidFromPhoneCollectionView.delegate = self
                                    }
                                }
                            }
                        }
                        self.ref.child("sessions").child(self.sessionID!).child("sessionPictureURL").observeSingleEvent(of: .value, with: { (snapshot) in
                            if self.profPicArray.count == 0{
                                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                    for snap in snapshots{
                                        
                                        if let url = NSURL(string: snap.value as! String){
                                            if let data = NSData(contentsOf: url as URL){
                                                self.profPicArray.append(UIImage(data: data as Data)!)
                                                
                                            }
                                        }
                                    }
                                    print("pArray: \(self.profPicArray)")
                                    
                                    //self.videoCollectEmpty = false
                                    for snap in snapshots{
                                        self.currentCollectID = "picsFromPhone"
                                        self.tempLink = NSURL(string: (snap.value as? String)!)
                                        
                                        //self.YoutubeArray.append(snap.value as! String)
                                        
                                        let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                                        self.picCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                                        
                                        self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                                        self.picCollectionView.backgroundColor = UIColor.clear
                                        self.picCollectionView.dataSource = self
                                        self.picCollectionView.delegate = self
                                        
                                    }
                                }
                            }
                        })
                    
                    }
                })
                self.viewDidAppearBool = true

            }
        }
        
    }
    
    

    
    override func viewDidLoad(){
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel" , style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.normal)
        
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
                    self.navigationController?.popViewController(animated: false)
                }
        });
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.currentCollectID == "youtube"{
            return youtubeLinkArray.count
            

        }
        if self.currentCollectID == "vidFromPhone"{
            return vidFromPhoneArray.count
        }
            else{
            return profPicArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentCollectID != "picsFromPhone"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.indexPath = indexPath
            
            //self.curIndexPath.append(indexPath)
            self.curCell = cell
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
            self.configurePictureCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            
            //self.curIndexPath.append(indexPath)
            
            return cell
        }
        
        
    }
    var vidRemovalPressed: Bool?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       if self.currentCollectID == "vidFromPhone" && self.vidRemovalPressed == false{
        if (self.vidFromPhoneCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playbackState == .playing {
            (self.vidFromPhoneCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.stop()
            
        }else{
            (self.vidFromPhoneCollectionView.cellForItem(at: indexPath) as! VideoCollectionViewCell).player?.playFromBeginning()
        }

        }
        
    }
    
    func configurePictureCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        if self.profPicArray.count != 0{
            print(indexPath.row)
            cell.picImageView.image = self.profPicArray[indexPath.row]//loadImageUsingCacheWithUrlString(String(describing: self.profPicArray[indexPath.row]))
            cell.picData = self.profPicArray[indexPath.row]
            cell.removePicDelegate = self
            cell.deleteButton.isHidden = false
        }
    }
    
    func configureCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        print(self.currentCollectID)
        if(self.currentCollectID == "youtube"){
            if self.youtubeLinkArray.isEmpty == true{
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.removeVideoButton.isHidden = true
                cell.videoURL = nil
                cell.player?.view.isHidden = true
                cell.youtubePlayerView.isHidden = true
                //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
                cell.removeVideoButton.isHidden = true
                cell.noVideosLabel.isHidden = false
            }else{
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
                cell.removeVideoButton.isHidden = false
                cell.removeVideoDelegate = self
                cell.youtubePlayerView.isHidden = false
                cell.player?.view.isHidden = true
                
                cell.isYoutube = true
                cell.videoURL = self.youtubeLinkArray[indexPath.row] //NSURL(string: self.youtubeArray[indexPath.row])
                cell.youtubePlayerView.loadVideoURL(self.youtubeLinkArray[indexPath.row] as URL)//NSURL(string: self.recentlyAddedVidArray[indexPath.row])!)
        
                cell.noVideosLabel.isHidden = true
            }
        }
        else{
            print("not youtube")
            if self.vidFromPhoneArray.count == 0 {
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.removeVideoButton.isHidden = true
                cell.videoURL = nil
                cell.player?.view.isHidden = true
                cell.youtubePlayerView.isHidden = true
                //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
                cell.removeVideoButton.isHidden = true
                cell.noVideosLabel.isHidden = false

            } else{
                cell.youtubePlayerView.isHidden = true
                cell.removeVideoButton.isHidden = false
                cell.noVideosLabel.isHidden = true
                cell.isYoutube = false
                cell.player?.view.isHidden = false
                cell.removeVideoDelegate = self
                cell.videoURL =  self.vidFromPhoneArray[indexPath.row] as NSURL?
                cell.player?.setUrl(self.vidFromPhoneArray[indexPath.row] as URL)
                //print(self.vidArray[indexPath.row])
                 //cell.youtubePlayerView.loadVideoURL(self.vidArray[indexPath.row] as URL)
            }
        }
    }
    var recentlyAddedPhoneVidArray = [NSURL]()
    @IBOutlet weak var newImage: UIImageView!
    var isYoutubeCell: Bool?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if currentPicker == "photo"{
        
            var selectedImageFromPicker: UIImage?
            
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
                selectedImageFromPicker = originalImage
            }
        
            if let selectedImage = selectedImageFromPicker {
                
                self.recentlyAddedPicArray.append(selectedImage)
                self.profPicArray.append(selectedImage)
                needToUpdatePics = true
                
                
                
                
                }
            
            
        
            self.dismiss(animated: true, completion: nil)
            
            
            let insertionIndexPath = IndexPath(row: self.profPicArray.count - 1, section: 0)
            
            DispatchQueue.main.async{
                
                print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                self.picCollectionView.insertItems(at: [insertionIndexPath])
                print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                
            }
            

            
        
        }else{
            if senderView == "main"{
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                movieURLFromPicker = movieURL
                dismiss(animated: true, completion: nil)
                //self.recentlyAddedPhoneVid.append(String(describing: movieURL))
               // self.vidFromPhoneArray.append(movieURL)
                //uploadMovieToFirebaseStorage(url: movieURL)
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
                                    tempArray.append(mediaKid.key)
                                }
                                if tempArray.contains("vidsFromPhone"){
                                   // self.tempLink = self.currentYoutubeLink
                                    self.currentCollectID = "vidFromPhone"
                                    //self.isYoutubeCell = false
                                    self.recentlyAddedPhoneVidArray.append(movieURL)
                                    self.vidFromPhoneArray.append(movieURL)
                                    //self.recentlyAddedVidArray.append(String(describing: movieURL))
                                    let insertionIndexPath = IndexPath(row: self.vidFromPhoneArray.count - 1, section: 0)
                                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])
                                        break
                                }else{
                                    self.currentCollectID = "vidFromPhone"
                                    //self.isYoutubeCell = false
                                    self.vidFromPhoneArray.append(movieURL)
                                    self.recentlyAddedPhoneVidArray.append(movieURL)
                                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                    self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                    
                                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                    self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                    self.vidFromPhoneCollectionView.dataSource = self
                                    self.vidFromPhoneCollectionView.delegate = self
                                    
                                    break
                                }
                            }
                        }
                    }//else if it doesnt contain media
                    else{
                        self.currentCollectID = "vidFromPhone"
                        self.vidFromPhoneArray.append(movieURL)
                        self.recentlyAddedPhoneVidArray.append(movieURL)
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                        self.vidFromPhoneCollectionView.dataSource = self
                        self.vidFromPhoneCollectionView.delegate = self
                        self.curCount += 1
                        
                    }
                })
                }
            }
            else{
                
                let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL
                var moviePath = String(describing: movieURL)
                print("MOVURL: \(movieURL)")
                print("MOVPath: \(moviePath)")
                    movieURLFromPicker = movieURL
                
                    dismiss(animated: true, completion: nil)
                    //self.recentlyAddedPhoneVid.append(String(describing: movieURL))
                    // self.vidFromPhoneArray.append(movieURL)
                    //uploadMovieToFirebaseStorage(url: movieURL)
                    ref.child("sessions").child(self.sessionID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                        var tempArray1 = [String]()
                        for snap in snapshots{
                            tempArray1.append(snap.key)
                        }
                        if tempArray1.contains("sessionMedia"){
                            for snap in snapshots{
                                
                                //heres the probbbbb
                                if snap.key == "sessionMedia"{
                                    let mediaKids = snap.value as! [String]
                                    var tempArray = [String]()
                                    var containsVid = false
                                    for vid in mediaKids{
                                        if vid.contains("yout") == false{
                                            containsVid = true
                                        }
                                    }
                                    if containsVid == false{
                                        // self.tempLink = self.currentYoutubeLink
                                        self.currentCollectID = "vidFromPhone"
                                        //self.isYoutubeCell = false
                                        if let data = NSData(contentsOf: movieURL as! URL){
                                            self.addedVidDataArray.append(data as Data)
                                            
                                        }
                                        self.recentlyAddedPhoneVidArray.append(movieURL!)
                                        self.vidFromPhoneArray.append(movieURL!)
                                        //self.recentlyAddedVidArray.append(String(describing: movieURL))
                                        let insertionIndexPath = IndexPath(row: self.vidFromPhoneArray.count - 1, section: 0)
                                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])
                                        break
                                    }else{
                                        self.currentCollectID = "vidFromPhone"
                                        //self.isYoutubeCell = false
                                        self.vidFromPhoneArray.append(movieURL!)
                                        if let data = NSData(contentsOf: movieURL as! URL){
                                            self.addedVidDataArray.append(data as Data)
                                            
                                        }
                                        self.recentlyAddedPhoneVidArray.append(movieURL!)
                                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                        
                                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                        self.vidFromPhoneCollectionView.dataSource = self
                                        self.vidFromPhoneCollectionView.delegate = self
                                        
                                        break
                                    }
                                }
                            }
                        }//else if it doesnt contain media
                        else{
                           
                            self.currentCollectID = "vidFromPhone"
                            self.vidFromPhoneArray.append(movieURL!)
                            if let data = NSData(contentsOf: movieURL as! URL){
                                self.addedVidDataArray.append(data as Data)
                                
                            }
                            self.recentlyAddedPhoneVidArray.append(movieURL!)
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                            self.vidFromPhoneCollectionView.dataSource = self
                            self.vidFromPhoneCollectionView.delegate = self
                            self.curCount += 1
                            
                        }
                    })
                }

            }

        
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    }


    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
        
}
//crashes when you click remove video button before view fully loads
