//
//  AboutViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 17/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loadWebpage()
    }
    
    // URL request for the National Science Week website
    private let request = URLRequest(url: URL.scienceWeekURL)
    private var attemptedCache = false
    private var timer: Timer? = nil
    
    // called when the view's components have completed loading
    // but before they have necessarily appeared
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()

        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // load the website request
        if webView.isBlank() {
            loadWebpage()
        }
    }
    
    private func loadWebpage() {
        activityIndicator.startAnimating()
        Logger.log("Attempting load of web page.")

        webView.load(request)

        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.cancelLoadWebpage), userInfo: nil, repeats: false)
    }
    
    @objc private func cancelLoadWebpage() {
        webView.stopLoading()
        loadCachedWebpage()
    }
    
    private func loadCachedWebpage() {
        if attemptedCache { return }
        attemptedCache = true
        Logger.log("Attempting load of cached web page.")
    
        if let cachedHTML = try? String(contentsOf: URL.webpageCacheURL) {
            webView.loadHTMLString(cachedHTML, baseURL: URL.scienceWeekURL)
            Logger.log("Completed load of cached web page.")
        } else {
            summonAlertView(message: "Something has gone wrong! Make sure you're connected to the internet, then refresh.")
        }
        
        activityIndicator.stopAnimating()
    }
    
    private func setTheme() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Theme.primaryTextColour]
        self.navigationController?.navigationBar.tintColor = Theme.primaryAccentColour
        self.navigationController?.navigationBar.barStyle = Theme.lightTheme ? .default : .black
        parentView?.backgroundColor = Theme.primaryBackgroundColour
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.lightTheme ? UIStatusBarStyle.default : .lightContent
    }
}

// MARK: WKNavigationDelegate functions

extension AboutViewController {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.log("Completed load of web page.")
        activityIndicator.stopAnimating()
        timer?.invalidate()
        
        if !attemptedCache {
            DispatchQueue.main.async {
                self.webView.getContent() { content in
                    if let content = content,
                        let _ = try? content.write(to: URL.webpageCacheURL, atomically: true, encoding: .utf8) {
                        Logger.log("Cached copy of webpage.")
                    }
                }
            }
        }
        
        attemptedCache = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.log("Failed load of web page.")
        loadCachedWebpage()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        Logger.log("Failed load of web page.")
        loadCachedWebpage()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return }
        
        // open links in Safari
        if url != URL.scienceWeekURL && url != URL.scienceWeekMenuURL {
            Logger.log("Loading web page: \(url)")
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
}
