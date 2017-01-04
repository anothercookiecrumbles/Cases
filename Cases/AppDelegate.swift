//
//  AppDelegate.swift
//  Cases
//
//  Created by Priyanjana Bengani on 1/3/17.
//  Copyright © 2017 anothercookiecrumbles. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let buttonImage = #imageLiteral(resourceName: "StatusBarButtonImage")
        
        if let button = statusItem.button {
            button.image = buttonImage
            button.action = #selector(togglePopover(sender:))
        }

        popover.contentViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

}

