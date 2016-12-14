//
//  ArtistFinderViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/8/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation


class ArtistFinderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SessionIDDest, PerformSegueInArtistFinderController, UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    
    
    @IBOutlet weak var InstrumentPicker: UIPickerView!
    
    @IBOutlet weak var artistCollectionView: UICollectionView!
    
    
    var sizingCell: ArtistCardCell?
    weak var getSessionID : GetSessionIDDelegate?
    var artistPageViewController: UIPageViewController!
    var artistArray = [Artist]()
    var ref = FIRDatabase.database().reference()
    var thisSession: String!
    var thisSessionObject: Session!
    var instrumentPicked: String!
    var profileArtistUID: String?
    var menuText = ["Guitar", "Bass Guitar", "Piano", "Saxophone", "Trumpet", "Stand-up Bass", "violin", "Drums", "Cello", "Trombone", "Vocals", "Mandolin", "Banjo", "Harp"]
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ArtistProfileViewController
        {
            vc.artistUID = profileArtistUID
        }

    }

    @IBOutlet weak var searchButton: UIButton!
    func performSegueToProfile(artistUID: String) {
        self.profileArtistUID = artistUID
        performSegue(withIdentifier: "FinderToProfile", sender: self)
        
    }
    
    @IBOutlet weak var distancePicker: UIPickerView!
    
    
    var coordinateUser1: CLLocation?
    var coordinateUser2: CLLocation?
    //var distance: Double?
    
    var tempLong: CLLocationDegrees?
    var tempLat: CLLocationDegrees?
    var distanceInMeters: Double?

    
    @IBAction func searchForArtistsPressed(_ sender: AnyObject) {
        
        artistArray = [Artist]()
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                var index = 0
                var artistsAlreadyInSession = [String]()
                for snap in snapshots{
                    if(snap.key != FIRAuth.auth()?.currentUser?.uid){FIRDatabase.database().reference().child("sessions").child(self.thisSession).child("sessionArtists").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            for snap in snapshots{
                                artistsAlreadyInSession.append(snap.value as! String)
                            }
                        }
                        if let dictionary = snap.value as? [String: Any] {
                            let artist = Artist()
                            artist.setValuesForKeys(dictionary)
                            if(artistsAlreadyInSession.contains(artist.artistUID!) == false){
                                
                                if(self.artistArray.contains(artist) == false){
                                    if(artist.instruments.contains(self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]) == true){
                                        self.instrumentPicked = self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]
                                        self.artistArray.append(artist)
                                        index += 1
                                        
                                    }
                                }
                                if(self.artistArray.contains(artist) == true){
                                    if(artist.instruments.contains(self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]) == false){
                                        self.artistArray.remove(at: index)
                                        index -= 1
                                        
                                    }
                                }
                            }
                        
                        
                            if self.artistArray.isEmpty{
                                return
                            }
                        self.InstrumentPicker.delegate = self
                        self.InstrumentPicker.dataSource = self
                        self.distancePicker.delegate = self
                        self.distancePicker.dataSource = self
                        
                                                        
                                

                        
                        let cellNib = UINib(nibName: "ArtistCardCell", bundle: nil)
                        self.artistCollectionView.register(cellNib, forCellWithReuseIdentifier: "ArtistCardCell")
                        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! ArtistCardCell?
                        
                        
                        

                        self.artistCollectionView.dataSource = self
                        self.artistCollectionView.delegate = self

                        self.artistCollectionView.reloadData()
                       
                        self.artistCollectionView.gestureRecognizers?.first?.cancelsTouchesInView = false
                        self.artistCollectionView.gestureRecognizers?.first?.delaysTouchesBegan = false
                        }

                    })
                        
                    }
                }
            }            
        }, withCancel: nil)
        
        
        self.reloadInputViews()
        
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        
        layout.minimumLineSpacing = 0
        artistCollectionView.collectionViewLayout = layout
        InstrumentPicker.selectRow(menuText.count/2, inComponent: 0, animated: true)
     
        
        
        
        
    }
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleBack), with: nil, afterDelay: 0)
        } else {
            
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if let dictionary = snap.value as? [String: AnyObject] {
                        let artist = Artist()
                        artist.setValuesForKeys(dictionary)
                        self.artistArray.append(artist)

                    }
                }
            }
                //self.artistCollectionView.gestureRecognizers?.first?.cancelsTouchesInView = false
                self.InstrumentPicker.delegate = self
                self.InstrumentPicker.dataSource = self
                self.distancePicker.delegate = self
                self.distancePicker.dataSource = self
                self.InstrumentPicker.selectRow(self.menuText.count/2, inComponent: 0, animated: false)
                
                /*let cellNib = UINib(nibName: "ArtistCardCell", bundle: nil)
                self.artistCollectionView.register(cellNib, forCellWithReuseIdentifier: "ArtistCardCell")
                self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! ArtistCardCell?
                self.artistCollectionView.backgroundColor = UIColor.clear
                self.artistCollectionView.dataSource = self
                self.artistCollectionView.delegate = self*/
                //self.sessionCollectionView!.reloadData()
                

                //self.artistPageViewController = self.storyboard?.instantiateViewController(withIdentifier: "UITutorialPageViewController") as! UIPageViewController
                //self.artistPageViewController.dataSource = self
                //self.artistPageViewController.delegate = self
                
                
               /*
                
                //initializing first aboutONBViewController
                let initialContentViewController = self.pageTutorialAtIndex(0) as ArtistViewData
                var viewControllers = [ArtistViewData]()
                viewControllers = [initialContentViewController]
                
                self.artistPageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
                
                //making pageView only take up top half of screen
                self.artistPageViewController.view.frame.size.height = self.view.frame.size.height/2
                //adding subview
                self.addChildViewController(self.artistPageViewController)
                self.view.addSubview(self.artistPageViewController.view)
                self.artistPageViewController.didMove(toParentViewController: self)*/
                
        }, withCancel: nil)
    }
}
    
    
    
    
    
        
    /*override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.artistCollectionView.contentInset
        let value = (self.view.frame.size.width - (self.artistCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value
        self.artistCollectionView.contentInset = insets
        self.artistCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }*/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return artistArray.count
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCardCell", for: indexPath as IndexPath) as! ArtistCardCell
        cell.delegate = self
        
        
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        return cell

        
    }
    
    
    
    /*public func numberOfSections(in collectionView: UICollectionView) -> Int{
        
    }*/
    
    func configureCell(_ cell: ArtistCardCell, forIndexPath indexPath: NSIndexPath) {
        
        switch UIScreen.main.bounds.width{
        case 320:
            
            cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width:320, height:396)
            
        case 375:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:375,height:396)
            
            
        case 414:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:396)

        default:
            cell.frame = CGRect(x: cell.frame.origin.x,y: cell.frame.origin.y,width:414,height:396)
            
            
            
        }
        

        //self.artistCollectionView.gestureRecognizers?.first?.cancelsTouchesInView = false
        cell.artistCardCellBioTextView.text = artistArray[indexPath.row].bio
        cell.artistCardCellNameLabel.text = artistArray[indexPath.row].name
        
        cell.artistCardCellImageView.loadImageUsingCacheWithUrlString(artistArray[indexPath.row].profileImageUrl.first!)
        cell.artistUID = artistArray[indexPath.row].artistUID
        cell.invitedSessionID = self.thisSession
        cell.buttonName = self.instrumentPicked
        cell.sessionDate = self.thisSessionObject.sessionDate
        
        self.ref.child("users").child(artistArray[indexPath.row].artistUID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                print(snapshots)
                
                for snap in snapshots{
        
                    
                        if snap.key == "long"{
                            self.tempLong = snap.value as? CLLocationDegrees
                            
                        }else{
                            self.tempLat = snap.value as? CLLocationDegrees
                        }
                    }
                
                print(self.tempLat)
                self.coordinateUser2 = CLLocation(latitude: self.tempLat!, longitude: self.tempLong!)
                let userID = FIRAuth.auth()?.currentUser?.uid
                self.ref.child("users").child(userID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        
                        for snap in snapshots{
                            
                            
                                if snap.key == "long"{
                                    self.tempLong = snap.value as? CLLocationDegrees
                                    
                                }else{
                                    self.tempLat = snap.value as? CLLocationDegrees
                                }
                            }
                    
                    
                        
                        self.coordinateUser1 = CLLocation(latitude: self.tempLat!, longitude: self.tempLong!)
                        
                        
                        
                        
                        
                        //self.coordinateUser1 = CLLocation(latitude: 5.0, longitude: 5.0)
                        //self.coordinateUser2 = CLLocation(latitude: 5.0, longitude: 3.0)
                        
                        self.distanceInMeters = self.coordinateUser1?.distance(from: self.coordinateUser2!) // result is in meters
                        print(self.distanceInMeters)
                        var distanceInMiles = Double(round(10*(self.distanceInMeters! * 0.000621371))/10)
                        cell.distanceLabel.text = String(distanceInMiles) + " miles"
                        
                        
                        /*if((distanceInMeters! as Double) <= 1609){
                         // under 1 mile
                         }
                         else
                         {
                         // out of 1 mile
                         }*/
                    }
                    
                    
                })
            }
            
            
        })

        
        
        
    }




    
    
    
   
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return menuText.count
    }
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = menuText[row]
        
        var myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
    }

    
    
    func handleBack() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let sessTemp = SessionMakerViewController()
        present(sessTemp, animated: true, completion: nil)
    }

    
    
}



