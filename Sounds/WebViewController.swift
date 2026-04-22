//
//  WebViewController.swift
//  Sounds
//
//  Created by Richard Taylor on 02/01/2019.
//  Copyright © 2019 Moocode Ltd. All rights reserved.
//

import Cocoa
import OSLog
import WebKit

private let log = Logger(subsystem: "com.moocode.Sounds", category: "WebView")

class WebViewController: NSViewController {
    var webView: WKWebView!

    private let trustedHosts: Set<String> = [
        "bbc.co.uk",
        "bbc.com",
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
                log.error("JS error: \(error.localizedDescription, privacy: .public) — script: \(js, privacy: .public)")
            }
        }
    }

}

extension WebViewController {
    private func isTrusted(url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        return trustedHosts.contains { host == $0 || host.hasSuffix("." + $0) }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        if isTrusted(url: url) {
            decisionHandler(.allow)
        } else {
            log.notice("Blocked navigation to untrusted host: \(url?.absoluteString ?? "unknown", privacy: .public)")
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let url = navigationResponse.response.url
        if isTrusted(url: url) {
            decisionHandler(.allow)
        } else {
            log.notice("Blocked response from untrusted host: \(url?.absoluteString ?? "unknown", privacy: .public)")
            decisionHandler(.cancel)
        }
    }
}

