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

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.isInspectable = true
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL(URL(string: "https://www.bbc.co.uk/sounds/stations")!)
    }

    public func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }
}

extension WebViewController {
    private func isTrusted(url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        return trustedHosts.contains { host == $0 || host.hasSuffix("." + $0) }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        let url = navigationAction.request.url
        if isTrusted(url: url) {
            return .allow
        }
        log.notice("Blocked navigation to untrusted host: \(url?.absoluteString ?? "unknown", privacy: .public)")
        return .cancel
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        let url = navigationResponse.response.url
        if isTrusted(url: url) {
            return .allow
        }
        log.notice("Blocked response from untrusted host: \(url?.absoluteString ?? "unknown", privacy: .public)")
        return .cancel
    }
}

