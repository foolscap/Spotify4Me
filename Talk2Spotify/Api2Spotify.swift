//
//  Api2Spotify.swift
//  Talk2Spotify4Me
//
//  Created by Lucas Backert on 02.11.14.
//  Copyright (c) 2014 Lucas Backert. All rights reserved.
//
import Foundation
import AppKit
import AVFoundation

struct Api2Spotify {
    static let osaStart = "tell application \"Spotify\" to"
    
    static func getState() ->String{
        return executeScript("player state")
    }

    static func getTitle() -> String{
        return executeScript("name of current track")
    }
    
    static func getAlbum() -> String{
        return executeScript("album of current track")
    }
    
    static func getArtist() -> String{
        return executeScript("artist of current track")
    }
    
    static func getCover() -> NSData{
        var result: NSData?
        let artworkURL = executeScript("artwork url of current track")

        if(artworkURL.containsString("spotify:localfileimage")){
            let artworkURLArray = artworkURL.componentsSeparatedByString(":")
            var artworkURLString = artworkURLArray[2]
            artworkURLString = artworkURLString.stringByRemovingPercentEncoding!
            
            let asset = AVURLAsset.init(URL: NSURL(fileURLWithPath: artworkURLString))
            let metadata = asset.commonMetadata
            for (_,element) in metadata.enumerate() {
                if element.commonKey == AVMetadataCommonKeyArtwork {
                    if element.dataValue != nil {
                        result = NSData(data: element.dataValue!)
                    }
                    break
                }
            }
        }else if(artworkURL.containsString("http://images.spotify.com/image/")){
            let urlSession = NSURLSession.sharedSession()
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: artworkURL)!)
            
            let taskWithRequest = urlSession.dataTaskWithRequest(urlRequest, completionHandler: {data, response, error -> Void in
                if(error != nil){
                    print("error: \(error)")
                }
                if(data != nil){
                    result = data!
                }else{
                    result = NSData()
                }
            })
            taskWithRequest.resume()
        }else if (artworkURL == ""){
            result = NSData()
        }
        
        var counter = 0
        while(result == nil && counter < 100){ //Wait for the task to finish
            usleep(10000)
            counter = counter + 1
        }
        
        if(result == nil) {result = NSData()}
        return result!
    }
    
    static func getVolume() -> String{
        return executeScript("sound volume")
    }
    
    static func setVolume(level: Int){
        executeScript("set sound volume to \(level)")
    }
    
    static func toNextTrack(){
        executeScript("next track")
    }
    
    static func toPreviousTrack(){
        executeScript("previous track")
    }
    
    static func toPlayPause(){
        executeScript("playpause")
    }
    
    static func executeScript(phrase: String) -> String{
        var output = ""
        if(isSpotifyOn()){
            let script = NSAppleScript(source: "\(osaStart) \(phrase)" )
            var errorInfo: NSDictionary?
            let descriptor = script?.executeAndReturnError(&errorInfo)
            if(descriptor?.stringValue != nil){
                output = descriptor!.stringValue!
            }

        }
        return output
    }
    
    static func isSpotifyOn() -> Bool{
        let spotifyapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client") as [NSRunningApplication]
        if spotifyapp.isEmpty {
            return false
        }else {
            return true
        }
    }
    
    // NOT USED AT THE MOMENT
    static func getDuration() -> String{
        return executeScript("duration of current track")
    }
    
    static func getPosition() -> String{
        return executeScript("position of current track")
    }
}

