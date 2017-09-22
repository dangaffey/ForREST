//
//  AnyAuthRequiredTests.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import XCTest
@testable import forrest

class AppAuthRequiredTests: XCTestCase
{
    var networkConfig: NetworkConfig?
    var httpClient: OAuthHttpClient?
    var mockService: MockService?
    var data: Any?
    
    override func setUp()
    {
        super.setUp()
        self.networkConfig = NetworkConfig.sharedInstance
        self.networkConfig!.setConfigProvider(configProvider: MockConfigProvider())
        self.networkConfig!.setStateProvider(stateProvider: MockStateProvider())
        
        self.httpClient = OAuthHttpClient.sharedInstance
        self.mockService = MockService.sharedInstance
        self.data = nil
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApplicationAuthentication()
    {
        let asyncExpectation = expectation(description: "applicationAuth")
        
        self.httpClient!.attemptAppAuthentication(
            successHandler: { () in
                debugPrint("Persisted")
                asyncExpectation.fulfill()
            },
            failureHandler: { (error: Error) in
                debugPrint(error)
                asyncExpectation.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.data != nil)
        }
    }
    
}

