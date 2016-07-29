//
//  TodayViewController.swift
//  Talk2Spotify4Me
//
//  Created by Lucas Backert on 02.11.14.
//  Copyright (c) 2014 Lucas Backert. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    override var nibName: String? {
        return "TodayViewController"
    }
    
    var widgetAllowsEditing = true
    
    let smState = "smState"
    let smTitle = "smTitle"
    let smAlbum = "smAlbum"
    let smArtist = "smArtist"
    let smCover = "smCover"
    let smVolume = "smVolume"
    let smShowCover = "smShowCover"
    let smShowAlbum = "smShowAlbum"
    let smShowVolumeSlide = "smShowVolumeSlide"
    let smShowPlayButtons = "smShowPlayButtons"
    
    let playImage = NSImage(named: "play")
    let pauseImage = NSImage(named: "pause")

    var initialize = true
    var defaults = NSUserDefaults(suiteName: "backert.apps")!
    var centerReceiver = NSDistributedNotificationCenter()
    var information = [String:AnyObject]()
    var controller = NCWidgetController.widgetController()
    
    @IBOutlet weak var titleOutput: NSTextField!
    @IBOutlet weak var albumOutput: NSTextField!
    @IBOutlet weak var artistOutput: NSTextField!
    @IBOutlet weak var coverOutput: NSImageView!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var playpauseButton: NSButton!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var previousButton: NSButton!
    @IBOutlet weak var buttonCollection: NSStackView!
    
    
    @IBOutlet weak var showCover: NSButton!
    @IBOutlet weak var showAlbum: NSButton!
    @IBOutlet weak var showVolumeSlide: NSButton!
    @IBOutlet weak var showPlayButtons: NSButton!
    
    var showCoverBoolean = true
    var showAlbumBoolean = true
    var showVolumeSlidesBoolean = true
    var showPlayButtonsBoolean = true
    
    @IBOutlet weak var CoverHight: NSLayoutConstraint!
    @IBAction func volumeSliderAction(sender: AnyObject) {
        let notify = NSNotification(name: "Talk2Spotify4Me", object: "volume\(sender.integerValue)")
        centerReceiver.postNotification(notify)
    }
    @IBAction func previousButton(sender: AnyObject) {
        let notify = NSNotification(name: "Talk2Spotify4Me", object: "back")
        centerReceiver.postNotification(notify)
    }
    @IBAction func nextButton(sender: AnyObject) {
        let notify = NSNotification(name: "Talk2Spotify4Me", object: "skip")
        centerReceiver.postNotification(notify)
    }
    @IBAction func playpauseButton(sender: AnyObject) {
        let notify = NSNotification(name: "Talk2Spotify4Me", object: "playpause")
        centerReceiver.postNotification(notify)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if initialize {
            self.information = self.defaults.persistentDomainForName("backert.apps")!
            
            if (  information[smShowCover] != nil) {
                showCoverBoolean = information[smShowCover] as! Bool
                if ( showCoverBoolean ){
                    showCover.state = 1
                    coverOutput.hidden = false
                }else{
                    showCover.state = 0
                    coverOutput.hidden = true
                }
            }else {
                information.updateValue(true, forKey: smShowCover)
            }
            
            if ( information[smShowAlbum] != nil) {
                showAlbumBoolean = information[smShowAlbum] as! Bool
                if ( showAlbumBoolean ){
                    showAlbum.state = 1
                    albumOutput.hidden = false
                }else{
                    showAlbum.state = 0
                    albumOutput.hidden = true
                }
            }else {
                information.updateValue(true, forKey: smShowAlbum)
            }
            
            if ( information[smShowPlayButtons] != nil) {
                showPlayButtonsBoolean = information[smShowPlayButtons] as! Bool
                if ( showPlayButtonsBoolean ){
                    showPlayButtons.state = 1
                    buttonCollection.hidden = false
                }else{
                    showPlayButtons.state = 0
                    buttonCollection.hidden = true
                }
            }else {
                information.updateValue(true, forKey: smShowPlayButtons)
            }
            
            if ( information[smShowVolumeSlide] != nil) {
                showVolumeSlidesBoolean = information[smShowVolumeSlide] as! Bool
                if ( showVolumeSlidesBoolean ){
                    showVolumeSlide.state = 1
                    volumeSlider.hidden = false
                }else{
                    showVolumeSlide.state = 0
                    volumeSlider.hidden = true
                }
            }else {
                information.updateValue(true, forKey: smShowVolumeSlide)
            }
            
            defaults.setPersistentDomain(information, forName: "backert.apps")
            defaults.synchronize()
            
            showCover.hidden = true
            showAlbum.hidden = true
            showPlayButtons.hidden = true
            showVolumeSlide.hidden = true
            
            setReceiver()

            initialize = false
        }
        checkForTalk2Spotify()
        
    }
    
    func setReceiver(){
        self.centerReceiver.addObserverForName("Talk2Spotify4Me", object: nil, queue: nil) { (note) -> Void in
            let cmd = note.object as! String
            if cmd == "finished" {
                self.refreshView()
                self.isSpotifyOn()
            }
        }
        self.centerReceiver.addObserverForName("com.spotify.client.PlaybackStateChanged", object: nil, queue: nil) { (note) -> Void in
            self.checkForTalk2Spotify()
            
            //further code may useable to show notification only if a new track is played
//            let trackInfo = note.userInfo
//            print(trackInfo)
//            if(trackInfo != nil){
//                print(trackInfo!["Player State"])
//                print(trackInfo!["Track ID"])
//            }
            
        }
    }
    
    func checkForTalk2Spotify(){
        let notify = NSNotification(name: "Talk2Spotify4Me", object: "update")
        let mainapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("backert.Talk2Spotify") as [NSRunningApplication]
        let spotifyIsOn = self.isSpotifyOn()
        if mainapp.isEmpty {
            titleOutput.stringValue = "Please start 'Talk2Spotify' application"
            self.albumOutput.stringValue = ""
            self.artistOutput.stringValue = ""
            self.coverOutput.image = nil
            
        }else {
            if spotifyIsOn {
                centerReceiver.postNotification(notify)
            }
        }
    }
    
    func refreshView(){
        self.information = self.defaults.persistentDomainForName("backert.apps")!
        let title = information[smTitle] as? String
        let album = information[smAlbum] as? String
        let artist = information[smArtist] as? String
        let volume = information[smVolume] as? String
        
        if (title != nil) {
            titleOutput.stringValue = title!
        }
        
        if (album != nil) {
            albumOutput.stringValue = album!
        }
        
        if (artist != nil) {
            artistOutput.stringValue = artist!
        }
        
        if (volume != nil) {
            let volumeAsInteger = Int(volume!)
            if (volumeAsInteger != nil && volumeAsInteger! >= 0 && volumeAsInteger! <= 100) {
                volumeSlider.integerValue = volumeAsInteger!
            }
        }
        
        let coverAsData = information[smCover] as? NSData

        if(coverAsData != nil){
            let imageobj = NSImage.init(data: coverAsData!)
            if( !coverAsData!.isEqualToData(NSData()) && imageobj != nil ){
                CoverHight.constant = CGFloat(64)
                coverOutput.image = imageobj
            }else{
                CoverHight.constant = CGFloat(0)
            }
        }
    
        let state = information[smState] as? String
        if (state != nil) {
            if state == "kPSP" {
                playpauseButton.image = pauseImage
            }else if state == "kPSp" {
                playpauseButton.image = playImage
            }
        }
    }
    
    func isSpotifyOn() -> Bool{
        let spotifyapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client") as [NSRunningApplication]
        if spotifyapp.isEmpty {
            controller.setHasContent(false, forWidgetWithBundleIdentifier: "backert.Talk2Spotify.Talk2Spotify4Me")
            return false
        }else {
            controller.setHasContent(true, forWidgetWithBundleIdentifier: "backert.Talk2Spotify.Talk2Spotify4Me")
            return true
        }
    }
    
    
    
    func widgetDidBeginEditing() {
        showCover.hidden = false
        showAlbum.hidden = false
        showPlayButtons.hidden = false
        showVolumeSlide.hidden = false
    }
    
    func widgetDidEndEditing() {
        showCover.hidden = true
        showAlbum.hidden = true
        showPlayButtons.hidden = true
        showVolumeSlide.hidden = true        
    }
    
    @IBAction func changeHiddenStateForCover(sender: NSButton) {
        self.information = self.defaults.persistentDomainForName("backert.apps")!
        
        if(sender.state == 1){
            information.updateValue(true, forKey: smShowCover)
            coverOutput.hidden = false
        }else{
            information.updateValue(false, forKey: smShowCover)
            coverOutput.hidden = true
        }
        
        defaults.setPersistentDomain(information, forName: "backert.apps")
        defaults.synchronize()
    }
    @IBAction func changeHiddenStateForAlbum(sender: NSButton) {
        self.information = self.defaults.persistentDomainForName("backert.apps")!
        
        if(sender.state == 1){
            information.updateValue(true, forKey: smShowAlbum)
            albumOutput.hidden = false
        }else{
            information.updateValue(false, forKey: smShowAlbum)
            albumOutput.hidden = true
        }
        
        defaults.setPersistentDomain(information, forName: "backert.apps")
        defaults.synchronize()
    }
    @IBAction func changeHiddenStateForPlayButtons(sender: NSButton) {
        self.information = self.defaults.persistentDomainForName("backert.apps")!
        
        if(sender.state == 1){
            information.updateValue(true, forKey: smShowPlayButtons)
            buttonCollection.hidden = false
        }else{
            information.updateValue(false, forKey: smShowPlayButtons)
            buttonCollection.hidden = true
        }
        
        defaults.setPersistentDomain(information, forName: "backert.apps")
        defaults.synchronize()
    }
    @IBAction func changeHiddenStateForVolumeSlide(sender: NSButton) {
        self.information = self.defaults.persistentDomainForName("backert.apps")!
        
        if(sender.state == 1){
            information.updateValue(true, forKey: smShowVolumeSlide)
            volumeSlider.hidden = false
        }else{
            information.updateValue(false, forKey: smShowVolumeSlide)
            volumeSlider.hidden = true
        }
        
        defaults.setPersistentDomain(information, forName: "backert.apps")
        defaults.synchronize()
    }
}