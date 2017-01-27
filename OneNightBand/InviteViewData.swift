//
//  InviteViewData.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/27/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class InviteViewData: UIViewController {
    
    var inviteSenderText: String!
    var sessionNameText: String!
    var instrumentNeededText: String!
    var dateText: String!
    var inviteID: String!
    var ref = FIRDatabase.database().reference()
    var sessionArtistsArray = [String]()
    var sessionArray = [String]()
    
    @IBOutlet weak var AcceptButton: UIButton!
    @IBAction func AcceptPressed(_ sender: AnyObject) {
        self.view.setNeedsDisplay()
        let currentUser = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("users").child(currentUser!).child("invites").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let dictionary = snap.value as? [String: Any] {
                        if dictionary["sessionID"] as! String == self.sessionNameText{
                            FIRDatabase.database().reference().child("users").child(currentUser!).child("activeSessions").observeSingleEvent(of: .value, with: { (snapshot) in
                                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                    for snap in snapshots{
                                        self.sessionArray.append(snap.value! as! String)
                                    }
                                    self.sessionArray.append(self.sessionNameText)
                                    var tempDict = [String : Any]()
                                    tempDict["activeSessions"] = self.sessionArray
                                    
                                    
                                    
                                    
                                    FIRDatabase.database().reference().child("users").child(currentUser!).updateChildValues(tempDict, withCompletionBlock: {(err, ref) in
                                        if err != nil {
                                            print(err as Any)
                                            return
                                        }
                                    })
                                }
                                
                                
                                
                                /*FIRDatabase.database().reference().child("sessions").child(self.sessionNameText).child("sessionArtists").observeSingleEvent(of: .value, with: { (snapshot) in
                                 
                                 if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                 for snap in snapshots{
                                 
                                 self.sessionArtistsArray.append(snap.value! as! String)
                                 }
                                 FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                                 
                                 if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                 for snap in snapshots{
                                 if(snap.key == FIRAuth.auth()?.currentUser?.uid){
                                 if let dictionary = snap.value as? [String: Any] {
                                 self.currentArtist = dictionary["artistUID"] as! String
                                 }
                                 
                                 }
                                 }
                                 
                                 
                                 
                                 
                                 self.sessionArtistsArray.append(self.currentArtist)
                                 }
                                 
                                 var values2 = [String: Any]()
                                 values2["sessionArtists"] = self.sessionArtistsArray
                                 FIRDatabase.database().reference().child("sessions").child(self.sessionNameText).updateChildValues(values2)
                                 
                                 })
                                 }
                                 })*/
                            })
                            
                            
                            
                            snap.ref.removeValue()
                        }
                    }
                }
            }
        })
        let newSessionArtist = [currentUser!: self.instrumentNeededText!]
        FIRDatabase.database().reference().child("sessions").child(self.sessionNameText).child("sessionArtists").updateChildValues(newSessionArtist)
        
        
        
        print("accepted")
        

    }
    @IBOutlet weak var declineButton: UIButton!

    
    @IBAction func declinedPressed(_ sender: AnyObject) {
        let currentUser = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("users").child(currentUser!).child("invites").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if let dictionary = snap.value as? [String: Any] {
                        if dictionary["sessionID"] as! String == self.sessionNameText{
                            snap.ref.removeValue()
                            
                        }
                    }
                }
            }
        })
        
        print("declined")

    }
    
    @IBOutlet weak var senderPicToProf: UIButton!
    @IBAction func senderPicToProfTouched(_ sender: AnyObject) {
    }
    //@IBOutlet weak var inviteSender: UILabel?
    lazy var inviteSender: UILabel = {
        var tempLabel = UILabel()
        tempLabel.textColor = UIColor.black
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    }()
    func setupInviteSender(){
        inviteSender.topAnchor.constraint(equalTo: senderPicToProf.bottomAnchor).isActive = true
        //inviteSender.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        inviteSender.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    lazy var sessionName: UILabel = {
        var tempLabel = UILabel()
        tempLabel.textColor = UIColor.white
        tempLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    }()
    func setupSessionName(){
        sessionName.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        sessionName.topAnchor.constraint(equalTo: inviteSender.bottomAnchor, constant: 5).isActive = true
        // inviteSender.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    lazy var instrumentNeeded: UILabel = {
        var tempLabel = UILabel()
        tempLabel.textColor = UIColor.white
        tempLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    }()
    func setupInstrumentNeeded(){
        instrumentNeeded.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        instrumentNeeded.topAnchor.constraint(equalTo: sessionName.bottomAnchor, constant: 5).isActive = true
        // inviteSender.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    lazy var date: UILabel = {
        var tempLabel = UILabel()
        tempLabel.textColor = UIColor.white
        tempLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        return tempLabel
    }()
    func setupDate(){
        date.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        date.topAnchor.constraint(equalTo: instrumentNeeded.bottomAnchor, constant: 5).isActive = true
        // inviteSender.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    
    
    var sessionInvitedTo = Session()
    
   
    var pageIndex: Int?
    var currentArtist = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AcceptButton.layer.borderWidth = 2
        AcceptButton.layer.borderColor = UIColor.green.withAlphaComponent(0.64).cgColor
        
        declineButton.layer.borderColor = UIColor.red.withAlphaComponent(0.68).cgColor
        declineButton.layer.borderWidth = 2
        
        view.addSubview(inviteSender)
        view.addSubview(sessionName)
        view.addSubview(instrumentNeeded)
        view.addSubview(date)
        
        setupInviteSender()
        setupSessionName()
        setupInstrumentNeeded()
        setupDate()
        
        
        FIRDatabase.database().reference().child("sessions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if snap.key == self.sessionNameText{
                    
                        let dictionary = snap.value as? [String: Any]
                        self.sessionInvitedTo.setValuesForKeys(dictionary!)
                        
                        self.sessionName.text = self.sessionInvitedTo.sessionName
                        self.instrumentNeeded.text = self.instrumentNeededText
                        self.date.text = self.sessionInvitedTo.sessionDate
                        let tempImage = UIImageView()
                        
                        tempImage.loadImageUsingCacheWithUrlString(self.sessionInvitedTo.sessionPictureURL! as String)
                        self.senderPicToProf.setImage(tempImage.image, for: .normal)

                        
                    }
                }
            }
            
        
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if(snap.key == FIRAuth.auth()?.currentUser?.uid){
                        if let dictionary = snap.value as? [String: Any] {
                            self.currentArtist = dictionary["name"] as! String
                        }

                    }
                    if snap.key == self.sessionInvitedTo.sessionArtists.first?.key{
                        if let dictionary = snap.value as? [String: Any]{
                            self.inviteSender.text = dictionary["name"] as? String
                        }
                    }
                
                }
            }
        })
        })
        

        
        
        
        
    }
}
