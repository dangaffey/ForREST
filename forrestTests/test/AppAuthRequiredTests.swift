//
//  AnyAuthRequiredTests.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import XCTest
@testable import ForREST

class AppAuthRequiredTests: XCTestCase
{
    var networkConfig: NetworkConfig?
    var httpClient: OAuthHttpClient?
    var mockService: MockService?
    var mockStateProvider: MockStateProvider?
    var data: Any?
    
    override func setUp()
    {
        super.setUp()
        self.networkConfig = NetworkConfig.sharedInstance
        self.mockStateProvider = MockStateProvider.sharedInstance
        
        self.networkConfig!.setConfigProvider(configProvider: MockConfigProvider())
        self.networkConfig!.setStateProvider(stateProvider: self.mockStateProvider!)
        self.networkConfig!.transportOverrideDomains = ["localhost"]
        
        self.httpClient = OAuthHttpClient.sharedInstance
        self.mockService = MockService.sharedInstance
        try! self.mockStateProvider!.setAppAccessData(token: "", expiration: "")
        
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
                asyncExpectation.fulfill()
            },
            failureHandler: { (error: Error) in
                asyncExpectation.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            debugPrint(error)
            XCTAssert(error == nil)
            XCTAssert(self.mockStateProvider!.appAccessTokenValid() == true)
        }
    }
    
    
    
    
}

