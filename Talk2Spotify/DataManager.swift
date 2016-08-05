//
//  DataManager.swift
//  Talk2Spotify4Me
//
//  Created by Lucas Backert on 05.11.14.
//  Copyright (c) 2014 Lucas Backert. All rights reserved.
//

import Foundation
import AppKit
import NotificationCenter

class DataManager {
    let smState = "smState"
    let smTitle = "smTitle"
    let smAlbum = "smAlbum"
    let smArtist = "smArtist"
    let smCover = "smCover"
    let smVolume = "smVolume"
    
    var defaults = NSUserDefaults(suiteName: "backert.apps")!
    var centerReceiver = NSDistributedNotificationCenter()
    var information: [String:AnyObject] = [:]
    init(){
        centerReceiver.addObserverForName("Talk2Spotify4Me", object: nil, queue: nil) { (note) -> Void in
            var defaultcase = false
            let cmd = note.object as? String
            if cmd != nil {
                switch cmd! {
                case "update":
                    self.update()
                case "playpause":
                    Api2Spotify.toPlayPause()
                case "skip":
                    Api2Spotify.toNextTrack()
                case "back":
                    Api2Spotify.toPreviousTrack()
                case "finished":
                    defaultcase = true
                    break
                case let volumestring :
                    if let range = volumestring.rangeOfString("volume") {
                        let stringVol:String = volumestring.substringFromIndex(range.endIndex)
                        Api2Spotify.setVolume(Int(stringVol)!)
                    }
                }
                
                if !defaultcase {
                    self.update()
                    let notify = NSNotification(name: "Talk2Spotify4Me", object: "finished")
                    self.centerReceiver.postNotification(notify)
                }
            }
        }
    }
    
    func update(){
        let informationcache = self.defaults.persistentDomainForName("backert.apps")
        if informationcache != nil { information = informationcache! }
        
        let state = Api2Spotify.getState()
        // state == "" is only returned if Spotify is not started, therefore no content check in the further context.
        if state != "" {
            information.updateValue(state, forKey: smState)
            if state != "kPSS" {
                information.updateValue(Api2Spotify.getTitle(), forKey: smTitle)
                information.updateValue(Api2Spotify.getAlbum(), forKey: smAlbum)
                information.updateValue(Api2Spotify.getArtist(), forKey: smArtist)
                information.updateValue(Api2Spotify.getCover(), forKey: smCover)
                information.updateValue(Api2Spotify.getVolume(), forKey: smVolume)
                
            }
            defaults.setPersistentDomain(information, forName: "backert.apps")
            defaults.synchronize()
        }else {
            information.updateValue("", forKey: smState)
            information.updateValue("", forKey: smTitle)
            information.updateValue("", forKey: smAlbum)
            information.updateValue("", forKey: smArtist)
            information.updateValue(NSData(), forKey: smCover)
            information.updateValue("100", forKey: smVolume)
            defaults.setPersistentDomain(information, forName: "backert.apps")
            defaults.synchronize()
        }
    }
}