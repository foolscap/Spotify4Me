//
//  AppDelegate.swift
//  Spotify
//
//  Created by Lucas Backert on 02.11.14.
//  Copyright (c) 2014 Lucas Backert. All rights reserved.
//

import Cocoa
import NotificationCenter

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    //var controller = NCWidgetController.widgetController()
    var dm = DataManager()
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
//        let app: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client") as [NSRunningApplication]
//        if app.isEmpty {
//            controller.setHasContent(false, forWidgetWithBundleIdentifier: "backert.SpotifyMain.SpotifyMain4Me")
//        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
//        controller.setHasContent(true, forWidgetWithBundleIdentifier: "backert.SpotifyMain.SpotifyMain4Me")
    }
}

