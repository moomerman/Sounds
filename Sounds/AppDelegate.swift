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
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var mediaKeyTap: MediaKeyTap?
    var webController: WebViewController?

    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = webController
        popover.contentSize.width = 900
        popover.contentSize.height = 600
        popover.behavior = .transient
        popover.delegate = self
        return popover
    }()

    lazy var detachedWindowController: NSWindowController = {
        let window = NSWindowController()
        window.contentViewController = webController
        return window
    }()

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
        popover.contentSize.height = 600
        popover.behavior = .transient

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
    }

    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

}

extension AppDelegate: MediaKeyTapDelegate {
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

extension AppDelegate: NSPopoverDelegate {
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }

    func detachableWindow(for popover: NSPopover) -> NSWindow? {
        return detachedWindowController.window
    }

    func popoverDidShow(_ notification: Notification) {
//        print("popoverDidShow")
    }

    func popoverDidClose(_ notification: Notification) {
//        print("popoverDidClose")
    }
}
