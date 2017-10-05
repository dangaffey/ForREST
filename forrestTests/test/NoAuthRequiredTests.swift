//
//  NoAuthRequiredTests.swift
//  forrestTests
//
//  Created by Daniel Gaffey on 9/20/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import XCTest
@testable import forrest

class NoAuthRequiredTests: XCTestCase
{
    var networkConfig: NetworkConfig?
    var mockService: MockService?
    var data: Any?
    
    override func setUp()
    {
        super.setUp()
        self.networkConfig = NetworkConfig.sharedInstance
        self.networkConfig!.setConfigProvider(configProvider: MockConfigProvider())
        self.networkConfig!.setStateProvider(stateProvider: MockStateProvider.sharedInstance)
        self.mockService = MockService.sharedInstance
        self.data = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAPIRequest()
    {
        let asyncExpectation = expectation(description: "GetAPINoAuth")
        
        self.mockService!.getNoAuthData(
            successHandler: { (data: Any) in
                self.data = data
                asyncExpectation.fulfill()
            },
            failureHandler: { (error: Any) in
                asyncExpectation.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.data != nil)
        }
    }
  
    
}
