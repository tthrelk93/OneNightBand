//
//  MP3PlayerViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 3/19/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//import DropDown

class MP3PlayerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var mp3Player:MP3Player?
    var timer:Timer?
    var sessionID:String?
    var mp3Names = [String]()
    var mediaItems = [MPMediaItem]()
    //var dropDown = DropDown()
    
    @IBOutlet weak var mp3Picker: UITableView!
    //now known as ShowMedia
    @IBOutlet weak var addMP3: UIButton!
    @IBAction func showSongsPressed(_ sender: Any) {
        addMP3.isHidden = true
        mp3Picker.isHidden = false
        self.mediaItems = MPMediaQuery.songs().items!
        // Or you can filter on various property
        // Like the Genre for example here
        /*var query = MPMediaQuery.songs()
        let predicateByGenre = MPMediaPropertyPredicate(value: "Rock", forProperty: MPMediaItemPropertyTitle )//MPMediaItemPropertyGenre)
        query.filterPredicates = NSSet(object: predicateByGenre) as! Set<MPMediaPredicate>*/
        for song in mediaItems{
            let cellNib = UINib(nibName: "songCell", bundle: nil)
            self.mp3Picker.register(cellNib, forCellReuseIdentifier: "SongCell")
            self.mp3Picker.delegate = self
            self.mp3Picker.dataSource = self
            mp3Names.append(song.title!)
        }
        for song in mediaItems{
            print(song.albumArtist!)
            
        }
        
        /*let mediaCollection = MPMediaItemCollection(items: mediaItems!)
       
        
        let player = MPMusicPlayerController.systemMusicPlayer()
        player.setQueue(with: mediaCollection)
        
        player.play()*/
        
    }
    @IBAction func backPressed(_ sender: Any) {
    }
    @IBOutlet weak var sessionBio: UITextView!
    @IBOutlet weak var sessionVidCollect: UICollectionView!
    @IBOutlet weak var sessionImagesCollect: UICollectionView!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackTime: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    var mp3URLArray = [URL]()
    override func viewDidLoad() {
        super.viewDidLoad()
        mp3Player = MP3Player()
        
        setupNotificationCenter()
        setTrackName()
        updateViews()
        navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        
        FIRDatabase.database().reference().child("sessions").child(sessionID!).child("mp3s").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                //fill datasources for collectionViews
                for snap in snapshots{
                    self.mp3URLArray.append(URL(string: (snap.value as! String))!)
                    
                }
            }
            DispatchQueue.main.async{
                self.mp3Player?.urls = self.mp3URLArray
            }
        })

        /*dropDown.selectionBackgroundColor = UIColor.orange.withAlphaComponent(0.4)
        dropDown.anchorView = self.view//collectionView.cellForItem(at: indexPath)
        dropDown.dataSource = ["beginner","intermediate","advanced","expert"]
        dropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            self.mp3Player.qu
        }
        dropDown.direction = .top
        //dropDown.selectRow(at: 1)
        dropDown.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dropDown.textColor = UIColor.white.withAlphaComponent(0.8)*/
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        //SwiftOverlays.removeAllBlockingOverlays()
    }
    @IBAction func playSong(_ sender: Any) {
        mp3Player?.play()
        startTimer()
    }
   
    @IBAction func stopSong(_ sender: Any) {
        mp3Player?.stop()
        updateViews()
        timer?.invalidate()
    }
    
    
    @IBAction func pauseSong(_ sender: Any) {
        mp3Player?.pause()
        timer?.invalidate()
    }
   
    @IBAction func playNextSong(_ sender: Any) {
        mp3Player?.nextSong(songFinishedPlaying: false)
        startTimer()
    }
    
    
    
    @IBAction func setVolume(_ sender: Any) {
         mp3Player?.setVolume(volume: (sender as AnyObject).value)
    }
    
    
    @IBAction func playPreviousSong(_ sender: Any) {
        mp3Player?.previousSong()
        startTimer()
    }
   
    
    func setTrackName(){
        trackName.text = (mp3Player?.getCurrentTrackName())!
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector("updateViews"), userInfo: nil, repeats: true)
    }
    
    func updateViewsWithTimer(theTimer: Timer){
        updateViews()
    }
    
    func updateViews(){
        trackTime.text = mp3Player?.getCurrentTimeAsString()
        if let progress = mp3Player?.getProgress() {
            progressBar.progress = progress
        }
    }
    
    func setupNotificationCenter(){
        NotificationCenter.default.addObserver(self,
                                                         selector:#selector(MP3PlayerViewController.setTrackName),
                                                         name:NSNotification.Name(rawValue: "SetTrackNameText"),
                                                         object:nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeMP3Touched(_ sender: Any) {
        addMP3.isHidden = false
        mp3Picker.isHidden = true
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print((self.thisSession.sessionArtists?.count)!)
        return self.mp3Names.count
    }
    var mp3URLString = [String]()
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //(tableView.cellForRow(at: indexPath) as ArtistCell).artistUID
        //self.cellTouchedArtistUID = (tableView.cellForRow(at: indexPath) as! ArtistCell).artistUID
        //performSegue(withIdentifier: "ArtistCellTouched", sender: self)
        //print(mediaItems[indexPath.row].assetURL)
        let mp3Name = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference(withPath: "bandMP3's").child("\(mp3Name).mp3")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "mp3"
        
            _ = storageRef.putFile(mediaItems[indexPath.row].assetURL!, metadata: uploadMetadata){(metadata, error) in
                if(error != nil){
                    print("got an error: \(error)")
                }
            
        }
        mp3URLArray.append(mediaItems[indexPath.row].assetURL!)
        for url in mp3URLArray{
            mp3URLString.append(String(describing: url))
        }
        var values2 = [String:Any]()
        values2["mp3s"] = mp3URLString
    
       FIRDatabase.database().reference().child("sessions").child(sessionID!).updateChildValues(values2, withCompletionBlock: {(err, ref) in
        if err != nil {
            print(err!)
            return
        }
    })
    }


    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath as IndexPath) as! songCell
        cell.nameLabel.text = mp3Names[indexPath.row]
        
        
        
        return cell
    }


}
