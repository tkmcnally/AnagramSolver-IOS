//
//  RestManagerTest.swift
//  AngramSolver
//
//  Created by Thomas McNally on 2015-08-27.
//  Copyright © 2015 Thomas McNally. All rights reserved.
//

import XCTest
@testable import AngramSolver

class RestManagerTest: XCTestCase {
    
    
    func testHTTPGetRequest() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let path = "http://services.aonaware.com/DictService/DictService.asmx/DefineInDict?dictId=string&word=string"

        RESTManager.singleton.makeHTTPGetRequest(path, callBack: helper)
    }

    
    func helper(xmlDoc: AEXMLDocument) {
        print("wooo")
    }
}
