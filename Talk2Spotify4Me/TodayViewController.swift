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
    
    let widgetAllowsEditing = true
    
    let smState = "smState"
    let smTitle = "smTitle"
    let smAlbum = "smAlbum"
    let smArtist = "smArtist"
    let smCover = "smCover"
    let smVolume = "smVolume"
    let smShowTitle = "smShowTitle"
    let smShowAlbum = "smShowAlbum"
    let smShowArtist = "smShowArtist"
    let smShowCover = "smShowCover"
    let smShowVolumeSlide = "smShowVolumeSlide"
    let smShowPlayButtons = "smShowPlayButtons"
    
    let playImage = NSImage(named: "play")
    let pauseImage = NSImage(named: "pause")

    var initialize = true
    var information = [String:AnyObject]()
    var defaults = NSUserDefaults(suiteName: "backert.apps")!
    var centerReceiver = NSDistributedNotificationCenter()
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
    
    @IBOutlet weak var showTitle: NSButton!
    @IBOutlet weak var showAlbum: NSButton!
    @IBOutlet weak var showArtist: NSButton!
    @IBOutlet weak var showCover: NSButton!
    @IBOutlet weak var showVolumeSlide: NSButton!
    @IBOutlet weak var showPlayButtons: NSButton!
    
    @IBOutlet weak var CoverHight: NSLayoutConstraint!
    
    @IBAction func volumeSliderAction(sender: AnyObject) {
        postNotification("volume\(sender.integerValue)")
    }
    @IBAction func previousButton(sender: AnyObject) {
        postNotification("back")
    }
    @IBAction func nextButton(sender: AnyObject) {
        postNotification("skip")
    }
    @IBAction func playpauseButton(sender: AnyObject) {
        postNotification("playpause")
    }
    
    func postNotification(note: String){
        let notify = NSNotification(name: "Talk2Spotify4Me", object: note)
        centerReceiver.postNotification(notify)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        if initialize { initializeApp() }
        checkForAppsAndUpdateView()
    }
    
    func initializeApp(){
        checkAndSetHiddenState(button: showTitle, smKey: smShowTitle, viewToHide: titleOutput)
        checkAndSetHiddenState(button: showAlbum, smKey: smShowAlbum, viewToHide: albumOutput)
        checkAndSetHiddenState(button: showArtist, smKey: smShowArtist, viewToHide: artistOutput)
        checkAndSetHiddenState(button: showCover, smKey: smShowCover, viewToHide: coverOutput)
        checkAndSetHiddenState(button: showPlayButtons, smKey: smShowPlayButtons, viewToHide: buttonCollection)
        checkAndSetHiddenState(button: showVolumeSlide, smKey: smShowVolumeSlide, viewToHide: volumeSlider)
        centerReceiver.addObserverForName("Talk2Spotify4Me", object: nil, queue: nil) { (note) -> Void in
            let cmd = note.object as! String
            if cmd == "finished" {
                self.refreshView()
            }
        }
        centerReceiver.addObserverForName("com.spotify.client.PlaybackStateChanged", object: nil, queue: nil) { (note) -> Void in
            self.checkForAppsAndUpdateView()
        }
        hideEditingOptions(true)
        initialize = false
    }
    
    func checkAndSetHiddenState(button button: NSButton, smKey: String, viewToHide: NSView){
        let informationcache = self.defaults.persistentDomainForName("backert.apps")
        if informationcache != nil { information = informationcache! }
        
        if information[smKey] != nil {
            let showView = information[smKey] as! Bool
            if showView {
                button.state = 1
                viewToHide.hidden = false
            }else{
                button.state = 0
                viewToHide.hidden = true
            }
        }else {
            information.updateValue(true, forKey: smKey)
        }
        
        defaults.setPersistentDomain(information, forName: "backert.apps")
        defaults.synchronize()
    }
    
    func refreshView(){
        let informationcache = self.defaults.persistentDomainForName("backert.apps")
        if informationcache != nil { information = informationcache! }

        titleOutput.stringValue = information[smTitle] as! String
        albumOutput.stringValue = information[smAlbum] as! String
        artistOutput.stringValue = information[smArtist] as! String
        let volAsInt = Int(information[smVolume] as! String)
        if volAsInt != nil && volAsInt! >= 0 && volAsInt! <= 100 { volumeSlider.integerValue = volAsInt! }
        
        let coverAsData = information[smCover] as? NSData
        if coverAsData != nil {
            let imageobj = NSImage.init(data: coverAsData!)
            if !coverAsData!.isEqualToData(NSData()) && imageobj != nil {
                CoverHight.constant = CGFloat(64)
                coverOutput.image = imageobj
            }else{
                CoverHight.constant = CGFloat(0)
            }
        }
    
        let state = information[smState] as? String
        if state != nil {
            if state == "kPSP" {
                playpauseButton.image = pauseImage
            }else if state == "kPSp" {
                playpauseButton.image = playImage
            }
        }
    }
    
    func checkForAppsAndUpdateView(){
        let mainapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("backert.Talk2Spotify") as [NSRunningApplication]
        if mainapp.isEmpty {
            titleOutput.stringValue = "Please start 'Talk2Spotify' application"
            albumOutput.stringValue = ""
            artistOutput.stringValue = ""
            coverOutput.image = nil
        }else {
            let spotifyapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client") as [NSRunningApplication]
            if spotifyapp.isEmpty {
                controller.setHasContent(false, forWidgetWithBundleIdentifier: "backert.Talk2Spotify.Talk2Spotify4Me")
            }else {
                controller.setHasContent(true, forWidgetWithBundleIdentifier: "backert.Talk2Spotify.Talk2Spotify4Me")
                postNotification("update")
            }
        }
    }
    
    func widgetDidBeginEditing() {
        hideEditingOptions(false)
    }

    func widgetDidEndEditing() {
        hideEditingOptions(true)
    }
    
    func hideEditingOptions(isHidden: Bool){
        showTitle.hidden = isHidden
        showAlbum.hidden = isHidden
        showArtist.hidden = isHidden
        showCover.hidden = isHidden
        showPlayButtons.hidden = isHidden
        showVolumeSlide.hidden = isHidden
    }
    
    @IBAction func changeHiddenStateForTitle(sender: NSButton) {
        changeHiddenState(button: sender,smKey: smShowTitle,viewToHide: titleOutput)
    }
    @IBAction func changeHiddenStateForAlbum(sender: NSButton) {
        changeHiddenState(button: sender,smKey: smShowAlbum,viewToHide: albumOutput)
    }
    @IBAction func changeHiddenStateForArtist(sender: NSButton) {
        changeHiddenState(button: sender,smKey: smShowArtist,viewToHide: artistOutput)
    }
    @IBAction func changeHiddenStateForCover(sender: NSButton) {
        changeHiddenState(button: sender,smKey: smShowCover,viewToHide: coverOutput)
    }
    @IBAction func changeHiddenStateForPlayButtons(sender: NSButton) {
        changeHiddenState(button: sender,smKey: smShowPlayButtons,viewToHide: buttonCollection)
    }
    @IBAction func changeHiddenStateForVolumeSlide(sender: NSButton) {
        changeHiddenState(button: sender,smKey: smShowVolumeSlide,viewToHide: volumeSlider)
    }
    
    func changeHiddenState(button button: NSButton, smKey: String, viewToHide: NSView){
        let informationcache = self.defaults.persistentDomainForName("backert.apps")
        if informationcache != nil { information = informationcache! }
        if(button.state == 1){
            information.updateValue(true, forKey: smKey)
            viewToHide.hidden = false
        }else{
            information.updateValue(false, forKey: smKey)
            viewToHide.hidden = true
        }
        defaults.setPersistentDomain(information, forName: "backert.apps")
        defaults.synchronize()
    }
}