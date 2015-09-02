//
//  RESTManager.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-08-27.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import Foundation

typealias ServiceResponse = (AEXMLDocument) -> Void

class RESTManager: NSObject {
    
    static let singleton = RESTManager()
    
    func makeHTTPGetRequest(path: String, callBack: ServiceResponse) {
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let url: NSURL = NSURL(string: path)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"

        let task = session.dataTaskWithRequest(request) { (data: NSData?,  response: NSURLResponse?, var error: NSError?) -> Void in
            let doc = AEXMLDocument(xmlData: data!, error: &error)
            dispatch_async(dispatch_get_main_queue()) {
                callBack(doc!)
            }
        }
        task.resume()
    }
}