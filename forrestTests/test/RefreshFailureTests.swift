//
//  RefreshFailureTests.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 11/11/19.
//  Copyright © 2019 UnchartedRealms. All rights reserved.
//

import XCTest
@testable import ForREST

class RefreshFailureTests: XCTestCase {
    
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
        
        self.networkConfig!.setConfigProvider(configProvider: MockBadRefreshConfigProvider())
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
    
    
    func testRefreshFail()
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

       
        let notificationExpectation = expectation(forNotification: Notifications.logout,
                                                           object: nil,
                                                          handler: nil)
        
        self.mockService!.getUserSecuredData(
            successHandler: { (data) in
                //refreshExpectation.fulfill()
            },
            failureHandler: { [weak self] (error) in
                self?.data = error
               // refreshExpectation.fulfill()
            }
        )
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
