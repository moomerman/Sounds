//
//  WebViewController.swift
//  Sounds
//
//  Created by Richard Taylor on 02/01/2019.
//  Copyright © 2019 Moocode Ltd. All rights reserved.
//

import Cocoa
import WebKit

class WebViewController: NSViewController {
    var webView: WKWebView!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL(URL(string:"https://www.bbc.co.uk/sounds/stations")!)
    }

    public func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    public func togglePlay() {
        execJS("document.getElementById(\"smphtml5iframesmp-wrapper\").contentWindow.document.getElementById(\"p_audioui_playpause\").click()")
    }

    public func live() {
        execJS("document.getElementById(\"smphtml5iframesmp-wrapper\").contentWindow.document.getElementById(\"p_audioui_toLiveButton\").click()")
    }

    public func start() {
        execJS("document.getElementById(\"smphtml5iframesmp-wrapper\").contentWindow.document.getElementById(\"p_audioui_backToStartButton\").click()")
    }

    private func execJS(_ js: String) {
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print(error)
            }
        }
    }

}

extension WebViewController {
    static func freshController() -> WebViewController {
        return WebViewController()
    }
}
