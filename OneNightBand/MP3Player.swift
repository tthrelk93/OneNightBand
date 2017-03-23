//
//  MP3Player.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 3/19/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MP3Player: NSObject, AVAudioPlayerDelegate {
    var player:AVAudioPlayer?
    var currentTrackIndex = 0
    //var tracks:[String] = [String]()
    var urls = [URL]()
    
    init(urlArray: [URL]){
        //tracks = FileReader.readFiles()
        self.urls = urlArray
        super.init()
        if self.urls.count > 0{
            queueTrack();
        }
    }
    
    func queueTrack(){
        if (player != nil) {
            player = nil
        }
        
        //var error:NSError?
        let url = NSURL(fileURLWithPath: String(describing: urls[currentTrackIndex]))
 //NSURL.fileURL(withPath: String(describing: urls[currentTrackIndex]))
       // NSURL(fileURLWithPath: String(describing: urls[currentTrackIndex]))
        /*player =   try AVAudioPlayer(contentsOf: url)
       if let hasError = error {
            //SHOW ALERT OR SOMETHING
        } else {
            player?.delegate = self
            player?.prepareToPlay()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SetTrackNameText"), object: nil)
        }*/
        
        do {
            player?.delegate = self
            player?.prepareToPlay()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SetTrackNameText"), object: nil)
            self.player = try AVAudioPlayer(contentsOf: url as URL)
            
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }

        
    }
    
    func play() {
        
        //print(player?.url?.lastPathComponent)
        if player?.isPlaying == false {
            player?.play()
        }
    }
    func stop(){
        if player?.isPlaying == true {
            player?.stop()
            player?.currentTime = 0
        }
    }
    func pause(){
        if player?.isPlaying == true{
            player?.pause()
        }
    }
    func nextSong(songFinishedPlaying:Bool){
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }
        
        currentTrackIndex += 1
        if currentTrackIndex >= urls.count {
            currentTrackIndex = 0
        }
        queueTrack()
        if playerWasPlaying || songFinishedPlaying {
            player?.play()
        }
    }
    func previousSong(){
        var playerWasPlaying = false
        if player?.isPlaying == true {
            player?.stop()
            playerWasPlaying = true
        }
        currentTrackIndex -= 1
        if currentTrackIndex < 0 {
            currentTrackIndex = urls.count - 1
        }
        
        queueTrack()
        if playerWasPlaying {
            player?.play()
        }
    }
    func getCurrentTrackName() -> String {
        let trackName = String(describing: urls[currentTrackIndex]).stringByDeletingLastPathComponent
        return (trackName)
    }
    func getCurrentTimeAsString() -> String {
        var seconds = 0
        var minutes = 0
        if let time = player?.currentTime {
            seconds = Int(time) % 60
            minutes = (Int(time) / 60) % 60
        }
        return String(format: "%0.2d:%0.2d",minutes,seconds)
    }
    func getProgress()->Float{
        var theCurrentTime = 0.0
        var theCurrentDuration = 0.0
        if let currentTime = player?.currentTime, let duration = player?.duration {
            theCurrentTime = currentTime
            theCurrentDuration = duration
        }
        return Float(theCurrentTime / theCurrentDuration)
    }
    func setVolume(volume:Float){
        player?.volume = volume
    }
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            nextSong(songFinishedPlaying: true)
        }
    }
}
extension String {
    public var url: NSURL { return NSURL(fileURLWithPath:self) }
    public var stringByDeletingLastPathComponent: String { return String(describing: url.lastPathComponent)}
}
