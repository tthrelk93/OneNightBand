//
//  CreateWantedAdViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 4/11/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftOverlays


class CreateWantedAdViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, Dismissable {
    
    @IBOutlet weak var bandImageView: UIImageView!
    //@IBOutlet weak var bandName: UILabel!
    @IBOutlet weak var instrumentPicker: UIPickerView!
    
    weak var dismissalDelegate: DismissalDelegate?
    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser?.uid
    var bandType = String()
    var bandID = String()
    var wantedIDArray = [String]()

    @IBAction func postAdPressed(_ sender: Any) {
        if(moreInfoTextView.text != "tap to add info about the type of musician you are looking for. This may include playing style, musical influences, etc... "){
            SwiftOverlays.showBlockingWaitOverlayWithText("Loading Your Bands")
            
            
           
            
            var tempArray2 = [String]()
            var values = Dictionary<String, Any>()
            tempArray2.append((FIRAuth.auth()?.currentUser?.uid)! as String)
            values["bandType"] =  self.bandType
            values["bandName"] = self.bandName
            values["bandID"] = self.bandID
            values["instrumentNeeded"] = [self.instrumentText[self.instrumentPicker.selectedRow(inComponent: 0)]]
            values["moreInfo"] = self.moreInfoTextView.text
            values["city"] = self.locationText[self.cityPicker.selectedRow(inComponent: 0)]
            if self.bandType == "band"{
                values["date"] = ""
            } else{
                values["date"] = self.onbDate
            }
            values["wantedImage"] = self.imageString
            values["experience"] = self.expText[self.expPicker.selectedRow(inComponent: 0)]
            values["senderID"] = self.user
            values["responses"] = [String:Any]()
                        
            let ref = FIRDatabase.database().reference()
            let wantedReference = ref.child("wantedAds").childByAutoId()
            let wantedReferenceAnyObject = wantedReference.key
            values["wantedID"] = wantedReferenceAnyObject
                        self.wantedIDArray.append(wantedReferenceAnyObject)
                        //print(sessReference.key)
                        //sessReference.childByAutoId()
                        wantedReference.updateChildValues(values, withCompletionBlock: {(err, ref) in
                            if err != nil {
                                print(err as Any)
                                return
                            }
                        })
            var userValues = [String:Any]()
            var userWantedAdArray = [String]()
            ref.child("users").child(user!).child("wantedAds").observeSingleEvent(of: .value, with: {(snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if let snapDict = snap.value as? [String:Any] {
                            let wantedID = snapDict["wantedID"]
                            userWantedAdArray.append(wantedID as! String)
                        }
                    }
                    userWantedAdArray.append(wantedReferenceAnyObject)
                }
                userValues["wantedAds"] = userWantedAdArray
                ref.child("users").child(self.user!).updateChildValues(userValues)
                
            })
            
            if self.bandType == "band"{
                self.ref.child("bands").child(bandID).child("wantedAds").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            self.wantedIDArray.append(snap.value as! String)
                        }
                    }
                    
                    var tempDict = [String:Any]()
                    tempDict["wantedAds"] = self.wantedIDArray
                    let bandRef = self.ref.child("bands").child(self.bandID)
                    bandRef.updateChildValues(tempDict, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err as Any)
                            return
                        }
                    })
                    self.dismissalDelegate?.finishedShowing()
                    self.removeAnimate()
                
                    //var sessionVals = Dictionary
                    //let userSessRef = ref.child("users").child(user).child("activeSessions")
                })
            } else {
                self.ref.child("oneNightBands").child(bandID).child("wantedAds").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        for snap in snapshots{
                            
                            self.wantedIDArray.append(snap.value as! String)
                        }
                    }
                    
                    
                    var tempDict = [String:Any]()
                    tempDict["wantedAds"] = self.wantedIDArray
                    let onbRef = self.ref.child("oneNightBands").child(self.bandID)
                    onbRef.updateChildValues(tempDict, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err as Any)
                            return
                        }
                    })
                    DispatchQueue.main.async{
                        self.performSegue(withIdentifier: "CreateWantedToBandBoard", sender: self)
                    }
                    //self.dismissalDelegate?.finishedShowing()
                    //self.removeAnimate()
                    
                    //var sessionVals = Dictionary
                    //let userSessRef = ref.child("users").child(user).child("activeSessions")
                })

            }

        }
                       // let user = FIRAuth.auth()?.curren
    }
    var coordinateText = [String]()
    @IBOutlet weak var moreInfoTextView: UITextView!
    @IBOutlet weak var cityPicker: UIPickerView!
    @IBOutlet weak var expPicker: UIPickerView!
    var bandName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        for (key, value) in cityDict{
            locationText.append(key)
            coordinateText.append(value)
        }
        locationText.sort()
        locationText.insert("Current City", at: 0)
        locationText.insert("All", at: 0)
        moreInfoTextView.delegate = self
        instrumentPicker.delegate = self
        cityPicker.delegate = self
        expPicker.delegate = self
        
        navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        
        moreInfoTextView.text = "tap to add info about the type of musician you are looking for. This may include playing style, musical influences, etc... "
        if self.bandType == "band"{
            ref.child("bands").child(bandID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if snap.key == "bandPictureURL"{
                            var tempArray = snap.value as! [String]
                            //self.bandImageView.loadImageUsingCacheWithUrlString(tempArray.first!)
                            self.imageString = tempArray.first!
                        }
                        if snap.key == "bandName"{
                            self.bandName = snap.value as! String
                        }
                    
                    }
                }
            })
        } else {
            ref.child("oneNightBands").child(bandID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if snap.key == "onbPictureURL"{
                            var tempArray = snap.value as! [String]
                            //self.bandImageView.loadImageUsingCacheWithUrlString(tempArray.first!)
                            self.imageString = tempArray.first!
                        }
                        if snap.key == "onbName"{
                            self.bandName = snap.value as! String
                        }
                        if snap.key == "onbDate"{
                            self.onbDate = snap.value as! String
                        }
                        
                    }
                }
            })

            
        }


        // Do any additional setup after loading the view.
    }
        var onbDate = String()
        var imageString = String()

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if moreInfoTextView.textColor == UIColor.white {
            moreInfoTextView.text = nil
            moreInfoTextView.textColor = UIColor.orange
        }
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        if moreInfoTextView.text.isEmpty {
            moreInfoTextView.text = "tap to add info about the type of musician you are looking for. This may include playing style, musical influences, etc... "
            moreInfoTextView.textColor = UIColor.white
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
                self.view.superview?.reloadInputViews()
            }
            SwiftOverlays.removeAllBlockingOverlays()
        });
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismissalDelegate?.finishedShowing()
        removeAnimate()
    }
    
    
    var locationText = [String]()
    var cityDict = ["New York":"","Los Angeles":"","Chicago":"","Houston":"","Philadelphia":"","Phoenix, AZ":"","San Antonio":"","San Diego":"","Dallas":"","San Jose":"", "Austin":"","Jacksonville": "","San Francisco":"","Indianapolis":"","Columbus":"", "Fort Worth":"","Charlotte":"","Detroit":"","El Paso":"","Seattle":"","Denver":"","Washington ":"","Memphis":"","Boston":"","Nashville":"","Atlanta":""]
    var instrumentText = ["All","Guitar", "Bass Guitar", "Piano", "Saxophone", "Trumpet", "Stand-up Bass", "violin", "Drums", "Cello", "Trombone", "Vocals", "Mandolin", "Banjo", "Harp"]
    /*var locationText = ["All","Near You","Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]*/
    var expText = ["Beginner","Intermediate","Advanced","Expert"]
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == self.cityPicker{
            return locationText.count
        }else if pickerView == self.instrumentPicker{
            return instrumentText.count
        } else {
            return expText.count
        }
    }
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == self.cityPicker{
            let titleData = locationText[row]
            
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
            return myTitle
        }else if pickerView == self.instrumentPicker{
            let titleData = instrumentText[row]
            
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
            return myTitle
            
        } else {
            let titleData = expText[row]
            
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
            return myTitle
        }
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView == self.cityPicker{
            
        }else if pickerView == self.instrumentPicker{
            
            
        } else {
            
        }

    }

    
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        SwiftOverlays.removeAllBlockingOverlays()
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BandBoardViewController{
            if self.bandType == "band"{
                vc.searchType = "Bands"
            } else {
                vc.searchType = "OneNightBands"
            }
        }
    }
    

}
