//
//  UploadSessionPopup.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 11/10/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase




class UploadSessionPopup: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FeedDismissable {
    weak var feedDismissalDelegate: FeedDismissalDelegate?
    
    
    @IBOutlet weak var uploadToLiveFeedButton: UIButton!
    @IBOutlet weak var addMediaButton: UIButton!
    @IBOutlet weak var feedPopupView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sessionCollectionView: UICollectionView!
    
    var sessionArray = [Session]()

    var sessionIDArray = [String]()
    var selectedSession = Session()

    var ref = FIRDatabase.database().reference()
    var sizingCell: SessionCell?
    var selectedCellCount = 0
 
       func backToFeed(){
        //let vc = SessionFeedViewController()
        //present(vc, animated: true, completion: nil)
        performSegue(withIdentifier: "CancelPressed", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.60)
        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(UploadSessionPopup.backToFeed))
        
        navigationItem.leftBarButtonItem = backButton
        
        //sessionCollectionView.allowsSelection = true
        loadPastAndCurrentSessions()
        sessionCollectionView.visibleCells.first?.layer.borderWidth = 2
        sessionCollectionView.visibleCells.first?.layer.borderColor = UIColor.orange.cgColor
        
    }
    
    func loadPastAndCurrentSessions(){
        let userID = FIRAuth.auth()?.currentUser?.uid
        //if(self.pastSessionsDidLoad == false){
        ref.child("users").child(userID!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    self.sessionIDArray.append((snap.value! as! String))
                }
                self.sessionCollectionView!.reloadData()
                
            }
            self.sessionCollectionView!.reloadData()
            self.ref.child("sessions").observeSingleEvent(of: .value, with: {(snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for id in self.sessionIDArray{
                    for snap in snapshots{
                        if snap.key == id{
                            let dictionary = snap.value as? [String: AnyObject]
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none
                            dateFormatter.dateStyle = DateFormatter.Style.short
                            let now = Date()
                            let order = Calendar.current.compare(now, to: self.dateFormatted(dateString: dictionary?["sessionDate"] as! String), toGranularity: .day)
                            
                            switch order {
                            case .orderedSame:
                                let tempSess = Session()
                                tempSess.setValuesForKeys(dictionary!)
                                self.sessionArray.append(tempSess)
                                
                            case .orderedAscending:
                                print("")
                                
                            case .orderedDescending:
                                let tempSess = Session()
                                tempSess.setValuesForKeys(dictionary!)
                                self.sessionArray.append(tempSess)
                                }
                            }
                        }
                    }
                }
                
                let cellNib = UINib(nibName: "SessionCell", bundle: nil)
                self.sessionCollectionView.register(cellNib, forCellWithReuseIdentifier: "SessionCell")
                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! SessionCell?
                self.sessionCollectionView.backgroundColor = UIColor.clear
                self.sessionCollectionView.dataSource = self
                self.sessionCollectionView.delegate = self
                self.sessionCollectionView!.reloadData()

                
                
            })
            

            
        })

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        return sessionArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath as IndexPath) as! SessionCell
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.orange.cgColor
        self.selectedSession = sessionArray[indexPath.row]
        cell?.isSelected = true
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.delegate = self
        
        
        present(imagePickerController, animated: true, completion: nil)
        /*collectionView.deselectItem(at: indexPath as IndexPath, animated: false)
        collectionView.cellForItem(at: indexPath)?.isSelected = !(collectionView.cellForItem(at: indexPath)?.isSelected)!
        collectionView.reloadData()*/
        //collectionView.cellForItem(at: indexPath)?.isSelected
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath){
        var cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.clear.cgColor
        cell?.isSelected = false
    }

    
    func configureCell(_ cell: SessionCell, forIndexPath indexPath: NSIndexPath) {
        
        cell.sessionCellImageView.loadImageUsingCacheWithUrlString(sessionArray[indexPath.row].sessionPictureURL!)
        cell.sessionCellLabel.text = sessionArray[indexPath.row].sessionName
        cell.sessionCellLabel.textColor = UIColor.black
        //cell.layer.borderWidth = cell.isSelected ? 2 : 0
        //cell.layer.borderColor = cell.isSelected ? UIColor.orange.cgColor : UIColor.clear.cgColor

        cell.sessionId = sessionArray[indexPath.row].sessionUID
        
        }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        /*if sessionBioTextView.textColor == UIColor.gray {
            sessionBioTextView.text = nil
            sessionBioTextView.textColor = UIColor.orange
        }*/
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        /*if sessionBioTextView.text.isEmpty {
            sessionBioTextView.text = "tap to add a little info about the type of session you are trying to create."
            sessionBioTextView.textColor = UIColor.gray
        }*/
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
    
    @IBAction func cancelTouched(_ sender: AnyObject) {
        feedDismissalDelegate?.finishedShowing(viewController: self)

        removeAnimate()
    }
    /*@IBAction func finalizeTouched(_ sender: AnyObject) {
        if(sessionImageView.image != nil && sessionNameTextField.text != "" && sessionBioTextView.text != "tap to add a little info about the type of session you are trying to create."){
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("session_images").child("\(imageName).jpg")
            
            if let sessionImage = self.sessionImageView.image, let uploadData = UIImageJPEGRepresentation(sessionImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    if let sessionImageUrl = metadata?.downloadURL()?.absoluteString {
                        var tempArray = [String]()
                        var tempArray2 = [String]()
                        var values = Dictionary<String, Any>()
                        tempArray2.append((FIRAuth.auth()?.currentUser?.uid)! as String)
                        values["sessionName"] =  self.sessionNameTextField.text
                        values["sessionArtists"] = tempArray2
                        values["sessionBio"] = self.sessionBioTextView.text
                        values["sessionPictureURL"] = sessionImageUrl
                        values["sessionMedia"] = ""
                        let dateformatter = DateFormatter()
                        
                        dateformatter.dateStyle = DateFormatter.Style.short
                        
                        //dateformatter.timeStyle = DateFormatter.Style.short
                        
                        let now = dateformatter.string(from: self.datePicker.date)
                        values["sessionDate"] = now
                        
                        
                        let ref = FIRDatabase.database().reference()
                        let sessReference = ref.child("sessions").childByAutoId()
                        
                        let sessReferenceAnyObject = sessReference.key
                        values["sessionUID"] = sessReferenceAnyObject
                        tempArray.append(sessReferenceAnyObject)
                        //print(sessReference.key)
                        //sessReference.childByAutoId()
                        sessReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if err != nil {
                                print(err)
                                return
                            }
                        })
                        let user = FIRAuth.auth()?.currentUser?.uid
                        //var sessionVals = Dictionary
                        //let userSessRef = ref.child("users").child(user).child("activeSessions")
                        self.ref.child("users").child(user!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                for snap in snapshots{
                                    tempArray.append(snap.value! as! String)
                                }
                            }
                            var tempDict = [String : Any]()
                            tempDict["activeSessions"] = tempArray
                            let userRef = ref.child("users").child(user!)
                            userRef.updateChildValues(tempDict, withCompletionBlock: {(err, ref) in
                                if err != nil {
                                    print(err)
                                    return
                                }
                            })
                            self.dismissalDelegate?.finishedShowing(viewController: self)
                            self.removeAnimate()
                            //this is ridiculously stupid way to reload currentSession data. find someway to fix
                            self.performSegue(withIdentifier: "FinalizeSessionToProfile", sender: self)
                            self.performSegue(withIdentifier: "CreateSessionPopupToCurrentSession", sender: self)
                        })
                    }
                })
            }
            
            
        }else{
            let alert = UIAlertController(title: "Error", message: "Missing Information", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }*/
    
    func dateFormatted(dateString: String)->Date{
        
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd-MM-yy"
        
        dateFormatter.dateFormat = "MM-dd-yy"
        //        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateObj = dateFormatter.date(from: dateString)
        
        
        return(dateObj)!
        
    }
    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    
    
    
    /*@IBAction func addMediaSelected(_ sender: AnyObject) {
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.mediaTypes = ["public.movie"]
        imagePickerController.delegate = self
        
        
        present(imagePickerController, animated: true, completion: nil)

    }*/
       
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL
        print(videoURL)
        print("picker done")
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }*/

    var sessionVideoURL: String?
    var downloadURL: URL?
    var mediaArray = [String]()
    var autoIdString = String()
    @IBAction func Upload(_ sender: AnyObject) {
        if movieURLFromPicker != nil{
            uploadMovieToFirebaseStorage(url: movieURLFromPicker!)
        }else{
            print("Missing Media")
        }
    }
    func uploadMovieToFirebaseStorage(url: NSURL){
        let videoName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference(withPath: "session_videos").child("\(videoName).mov")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "video/quicktime"
        let uploadTask = storageRef.putFile(url as URL, metadata: uploadMetadata){(metadata, error) in
            if(error != nil){
                print("got an error: \(error)")
            }else{
                print("upload complete: metadata = \(metadata)")
                print("download url = \(metadata?.downloadURL())")
                let recipient = self.ref.child("sessionFeed")
                let recipient2 = self.ref.child("sessions").child(self.selectedSession.sessionUID!)
                print(self.selectedSession)
                for cell in self.sessionCollectionView.visibleCells{
                    if cell.isSelected == true{
                        print("isSelected")
                        FIRDatabase.database().reference().child("sessionFeed").observeSingleEvent(of: .value, with:
                            { (snapshot) in
                                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                    print("inside snapshot: \(snapshots)")
                                    var values = Dictionary<String, Any>()
                                    var values2 = Dictionary<String, Any>()
                                    
                                        values["sessionName"] = self.selectedSession.sessionName
                                        values["sessionArtists"] = self.selectedSession.sessionArtists
                                        values["sessionBio"] = self.selectedSession.sessionBio
                                        values["sessionDate"] = self.selectedSession.sessionDate
                                        values["sessionUID"] = self.selectedSession.sessionUID
                                        values["sessionPictureURL"] = self.selectedSession.sessionPictureURL
                                        // values["sessionMedia"] = metadata?.downloadURL()?.absoluteString
                                        
                                        //values2["sessionMedia"] = metadata?.downloadURL()?.absoluteString
                                        
                                        let currentUser = FIRAuth.auth()?.currentUser?.uid
                                        FIRDatabase.database().reference().child("users").child(currentUser!).child("sessionMedia").observeSingleEvent(of: .value, with: { (snapshot) in
                                            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                                for snap in snapshots{
                                                    self.mediaArray.append(snap.value! as! String)
                                                }
                                                self.mediaArray.append((metadata?.downloadURL()?.absoluteString)!)
                                                var tempArray = [String]()
                                                tempArray.append((metadata?.downloadURL()?.absoluteString)!)
                                                values["sessionMedia"] = tempArray
                                                values2["sessionMedia"] = self.mediaArray
                                                let autoId = recipient.childByAutoId()
                                                //self.autoIdString = String(describing: autoId)
                                                autoId.updateChildValues(values, withCompletionBlock: {(err, ref) in
                                                    if err != nil {
                                                        print(err as Any)
                                                        return
                                                    }
                                                })
                                                recipient2.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                                                    if err != nil {
                                                        print(err)
                                                        return
                                                    }
                                                })
                                            }
                                        })
                                        

                                    
                                    for snap in snapshots{
                                        let tempDict = snap.value as! [String: Any]
                                        if tempDict["sessionUID"] as! String == self.selectedSession.sessionUID! as String{
                                            print("if")
                                            
                                        FIRDatabase.database().reference().child("sessions").child(self.selectedSession.sessionUID! as String).child("sessFeedKeys").observeSingleEvent(of: .value, with: {(snapshot) in
                                                var sessFeedKeyArray = snapshot.value as! [String]
                                     sessFeedKeyArray.append(self.autoIdString)
                                           values["sessFeedKeys"] = sessFeedKeyArray
                                     
                                     
                                            recipient2.updateChildValues(values, withCompletionBlock: {(err, ref) in
                                                if err != nil {
                                                    print(err as Any)
                                                    return
                                                }
                                            })
                                            
                                            
                                            
                                            })
                                        }
                                        
                                    }
                                    }
                                
                        })
                    }
            
                }

            }
    }
        /*uploadTask.observe(.progress){[weak self] (snapshot) in
            guard let strongSelf = self else {return}
            guard let progress = snapshot.progress else {return}
            strongSelf.progressView.progress = Float(progress.fractionCompleted)
            print("Uploaded \(progress.completedUnitCount) so far")
        }*/
    }
    var movieURLFromPicker: NSURL?
    
}

extension UploadSessionPopup: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        //guard let mediaType: String = info[UIImagePickerControllerMediaType] as? String else {
        //    dismiss(animated: true, completion: nil)
        //    return
            
       // }
        //if mediaType ==  "public.movie"{
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                movieURLFromPicker = movieURL
                dismiss(animated: true, completion: nil)
                //uploadMovieToFirebaseStorage(url: movieURL)
            }
            
        //}
    }
    
    @available(iOS 2.0, *)
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
        
    }
}



