//
//  UserAuthRequiredTests.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 9/29/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import XCTest
@testable import ForREST

class UserAuthRequiredTests: XCTestCase
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
        try! self.mockStateProvider!.setUserAccessData(token: "", expiration: "")
        try! self.mockStateProvider!.setUserRefreshData(token: "", expiration: "")
        self.data = nil
    }
    
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testUserAuth()
    {
        let asyncExpectation = expectation(description: "userAuth")
        
        self.httpClient!.attemptUserAuthentication(
            username: "testuser",
            password: "Testing1!",
            successHandler: { ([String: AnyObject]?) in
                asyncExpectation.fulfill()
            },
            failureHandler: { (error: ForRESTError) in
                asyncExpectation.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.mockStateProvider!.userAccessTokenValid())
        }
    }
    
    
    
    func testUserRefresh()
    {
        let asyncExpectation = expectation(description: "userLogin")
        
        self.httpClient!.attemptUserAuthentication(
            username: "testuser",
            password: "Testing1!",
            successHandler: { ([String: AnyObject]?) in
                asyncExpectation.fulfill()
            },
            failureHandler: { (error: ForRESTError) in
                asyncExpectation.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.mockStateProvider!.userAccessTokenValid() == true)
        }
        
        try! self.mockStateProvider!.setUserAccessData(token: "", expiration: "")
        XCTAssert(self.mockStateProvider!.userAccessTokenValid() == false)

        let refreshExpectation = expectation(description: "implicitRefresh")
        
        self.mockService!.getUserSecuredData(
            successHandler: { (data) in
                self.data = data
                refreshExpectation.fulfill()
            },
            failureHandler: { (error) in
                debugPrint(error)
                refreshExpectation.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.data != nil)
        }
    }
    
}
