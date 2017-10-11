//
//  NetworkConfigTests.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 10/11/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import XCTest
@testable import ForREST

class NetworkConfigTests: XCTestCase {
    
    var networkConfig: NetworkConfig?
    
    override func setUp() {
        super.setUp()
        self.networkConfig = NetworkConfig.sharedInstance
        self.networkConfig?.transportOverrideDomains = ["https://www.example.com"]
        
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testDomain() {
        debugPrint(self.networkConfig?.sslOverridePolicy)
    }
}
