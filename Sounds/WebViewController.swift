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

    private let trustedHosts: Set<String> = [
        "www.bbc.co.uk",
    ]

    private enum Selectors {
        static let iframeWrapperID = "smphtml5iframesmp-wrapper"
        static let playPauseButtonID = "p_audioui_playpause"
        static let liveButtonID = "p_audioui_toLiveButton"
        static let backToStartButtonID = "p_audioui_backToStartButton"
    }

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
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
        execJS(jsClickButtonInIframe(buttonID: Selectors.playPauseButtonID))
    }

    public func live() {
        execJS(jsClickButtonInIframe(buttonID: Selectors.liveButtonID))
    }

    public func start() {
        execJS(jsClickButtonInIframe(buttonID: Selectors.backToStartButtonID))
    }

    private func jsClickButtonInIframe(buttonID: String) -> String {
        return "document.getElementById(\"\(Selectors.iframeWrapperID)\").contentWindow.document.getElementById(\"\(buttonID)\").click()"
    }

    private func execJS(_ js: String) {
        webView.evaluateJavaScript(js) { (result, error) in
            if let error = error {
                print("JS Error: \(error)\nScript: \(js)")
            }
        }
    }

}

extension WebViewController {
    private func isTrusted(url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        if trustedHosts.contains(host) { return true }
        for base in trustedHosts {
            if host == base { return true }
            if host.hasSuffix("." + base) { return true }
        }
        return false
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if isTrusted(url: url) {
            decisionHandler(.allow)
        } else {
            print("Blocked navigation to untrusted host: \(url?.absoluteString ?? "unknown")")
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let url = navigationResponse.response.url
        if isTrusted(url: url) {
            decisionHandler(.allow)
        } else {
            print("Blocked response from untrusted host: \(url?.absoluteString ?? "unknown")")
            decisionHandler(.cancel)
        }
    }
}

extension WebViewController {
    static func freshController() -> WebViewController {
        return WebViewController()
    }
}

