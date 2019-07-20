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
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // URL request for the National Science Week website
    private let request = URLRequest(url: URL.scienceWeekURL)
    
    // called when the view's components have completed loading
    // but before they have necessarily appeared
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()

        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        // load the website request
        if webView.isBlank {
            loadWebpage()
        }
    }
    
    private func loadWebpage() {
        activityIndicator.startAnimating()
        Logger.log("Attempting load of web page.")
        webView.load(request)
    }
    
    private func setTheme() {
        navigationBar.titleTextAttributes = [.foregroundColor: Theme.primaryTextColour]
        navigationBar.tintColor = Theme.primaryAccentColour
        navigationBar.barStyle = Theme.lightTheme ? .default : .black
        parentView.backgroundColor = Theme.primaryBackgroundColour
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
    }
    
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        Logger.log("Failed load of web page.")
        activityIndicator.stopAnimating()
        
        if error.code == NSURLErrorNotConnectedToInternet {
            webView.loadHTMLString("<b>Oops, something went wrong.</b>",baseURL:  nil)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return }
        
        // open links in Safari
        if url != URL.scienceWeekURL {
            Logger.log("Loading web page: \(url)")
            decisionHandler(.cancel)
            UIApplication.shared.open(url)
        } else {
            decisionHandler(.allow)
        }
    }
}
