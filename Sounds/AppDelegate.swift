//
//  AppDelegate.swift
//  Sounds
//
//  Created by Richard Taylor on 02/01/2019.
//  Copyright © 2019 Moocode Ltd. All rights reserved.
//

import Cocoa
import MediaKeyTap

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, MediaKeyTapDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popover = NSPopover()
    var mediaKeyTap: MediaKeyTap?
    var eventMonitor: EventMonitor?
    var webController: WebViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        webController = WebViewController.freshController()
        DispatchQueue.main.async {
            self.webController?.view.needsLayout = true
        }

        mediaKeyTap = MediaKeyTap(delegate: self)
        mediaKeyTap?.start()

        let icon = NSImage(named: "status")
        icon?.isTemplate = true
        if let button = statusItem.button {
            button.image = icon
            button.action = #selector(togglePopover(_:))
        }

        popover.contentViewController = webController
        popover.contentSize.width = 900
        popover.contentSize.height = 570

        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }

        DispatchQueue.main.async {
            self.showPopover(sender: self)
            self.closePopover(sender: self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }

    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }

    func handle(mediaKey: MediaKey, event: KeyEvent) {
        switch mediaKey {
        case .playPause:
            webController?.togglePlay()
        case .previous, .rewind:
            webController?.start()
        case .next, .fastForward:
            webController?.live()
        }
    }
}
