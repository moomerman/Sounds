//
//  AppDelegate.swift
//  Sounds
//
//  Created by Richard Taylor on 02/01/2019.
//  Copyright © 2019 Moocode Ltd. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var mediaKeyTap: MediaKeyTap?
    var webController: WebViewController?

    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = webController
        popover.contentSize.width = 1060
        popover.contentSize.height = 670
        popover.behavior = .transient
        popover.delegate = self
        return popover
    }()

    lazy var detachedWindowController: NSWindowController = {
        let controller = NSWindowController()
        controller.window?.isMovableByWindowBackground = true
        controller.window?.styleMask = .fullSizeContentView
        controller.contentViewController = webController
        return controller
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
            button.action = #selector(handleStatusBarClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        popover.contentViewController = webController
        popover.contentSize.width = 1060
        popover.contentSize.height = 670
        popover.behavior = .transient

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showPopover(sender: nil)
        }
    }

    @objc func handleStatusBarClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover(sender)
        }
    }

    func showContextMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false

        addAppControlItems(to: menu)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
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

extension AppDelegate {

    func addAppControlItems(to menu: NSMenu) {
        let showMainItem = NSMenuItem(title: "Open Sounds", action: #selector(showMainWindow), keyEquivalent: "")
        showMainItem.target = self
        showMainItem.isEnabled = true
        menu.addItem(showMainItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        quitItem.isEnabled = true
        menu.addItem(quitItem)
    }
}

extension AppDelegate {

    @objc func showMainWindow() {
        showPopover(sender: nil)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

}
