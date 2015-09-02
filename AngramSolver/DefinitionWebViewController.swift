//
//  DefinitionWebViewController.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-09-01.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import UIKit
import WebKit

class DefinitionWebViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var baseUrl = "http://www.merriam-webster.com/dictionary/"
    var word = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = WKWebView()
        self.webView.navigationDelegate = self
        view = webView
        
        baseUrl += word.lowercaseString
        let url = NSURL (string: baseUrl)
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
        webView.allowsBackForwardNavigationGestures = true
        
        navigationItem.title = "Definition of " + word
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}