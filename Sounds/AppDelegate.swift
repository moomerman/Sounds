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
        popover.contentSize.width = Constants.popoverWidth
        popover.contentSize.height = Constants.popoverHeight
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
        popover.contentViewController = webController
        self.webController?.view.needsLayout = true

        mediaKeyTap = MediaKeyTap(delegate: self)
        mediaKeyTap?.start()

        setupStatusBarItem()

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.launchDelay) {
            self.showPopover(sender: nil)
        }
    }

    private func setupStatusBarItem() {
        let icon = NSImage(named: "status")
        icon?.isTemplate = true

        guard let button = statusItem.button else { return }
        button.image = icon
        button.action = #selector(handleStatusBarClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
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
        mediaKeyTap = nil
        popover.contentViewController = nil
        webController = nil
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
}

extension AppDelegate {
    private enum Constants {
        static let popoverWidth: CGFloat = 1060
        static let popoverHeight: CGFloat = 670
        static let launchDelay: TimeInterval = 0.5
    }

    func addAppControlItems(to menu: NSMenu) {
        let showMainItem = NSMenuItem(title: "Open Sounds", action: #selector(showMainWindow), keyEquivalent: "")
        showMainItem.target = self
        showMainItem.isEnabled = true
        menu.addItem(showMainItem)

        menu.addItem(NSMenuItem.separator())

        let aboutItem = NSMenuItem(title: "About Sounds", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        aboutItem.isEnabled = true
        menu.addItem(aboutItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        quitItem.isEnabled = true
        menu.addItem(quitItem)
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Sounds"
        alert.informativeText = """
        A BBC Sounds status bar app for macOS

        Built with ♥ for BBC Sounds listeners

        github.com/moomerman/Sounds
        v\(Bundle.main.appVersion)
        """
        alert.alertStyle = .informational
        alert.icon = NSImage(named: "AppIcon") ?? NSImage(named: "status")
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc func showMainWindow() {
        showPopover(sender: nil)
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}

extension Bundle {
    var appName: String {
        return infoDictionary?["CFBundleName"] as? String ?? "Sounds"
    }

    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
