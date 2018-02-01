//
//  CacheTests.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 1/31/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//


import XCTest
import Alamofire
@testable import ForREST

class CacheTests: XCTestCase {
    
    var networkConfig: NetworkConfig?
    var cacheService: CacheService?
    var data: Any?
    
    override func setUp()
    {
        super.setUp()
        
        URLCache.shared.removeAllCachedResponses()
        
        self.networkConfig = NetworkConfig.sharedInstance
        self.networkConfig!.stripMustRevalidate = true
        self.networkConfig!.setConfigProvider(configProvider: MockConfigProvider())
        self.networkConfig!.setStateProvider(stateProvider: MockStateProvider.sharedInstance)
        self.cacheService = CacheService.sharedInstance
        self.data = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPublicCacheRequest()
    {
        let asyncExpectation = expectation(description: "GetPublicCache")
        self.cacheService?.getPublicCache(
            successHandler: { (data) in
                self.data = data
                sleep(1)
                self.cacheService?.getPublicCache(
                    successHandler: { (data) in
                        self.data = data
                        
                },
                    failureHandler: { (error) in
                        
                }
                )
                
                
                self.cacheService?.getPublicCache(
                    successHandler: { (data) in
                        self.data = data
                        
                },
                    failureHandler: { (error) in
                        
                }
                )
                
                
                
                self.cacheService?.getPublicCache(
                    successHandler: { (data) in
                        self.data = data
                        
                },
                    failureHandler: { (error) in
                        
                }
                )
                
                
                self.cacheService?.getPublicCache(
                    successHandler: { (data) in
                        self.data = data
                        
                },
                    failureHandler: { (error) in
                        
                }
                )
                
                
                sleep(2)
                asyncExpectation.fulfill()
            },
            failureHandler: { (error) in
                asyncExpectation.fulfill()
            }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.data != nil)
       //     XCTAssert(URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: Endpoints.GET_PUBLIC_CACHE)!)) != nil)
        }
    }
    
    
    
    func testPrivateCacheRequest()
    {
        let asyncExpectation = expectation(description: "GetPrivateCache")
        self.cacheService?.getPrivateCache(
            successHandler: { (data) in
                self.data = data
                asyncExpectation.fulfill()
        },
            failureHandler: { (error) in
                asyncExpectation.fulfill()
        }
        )
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssert(error == nil)
            XCTAssert(self.data != nil)
            
            sleep(2)
            self.cacheService?.getPrivateCache(
                successHandler: { (data) in
                    self.data = data
                },
                failureHandler: { (error) in
                }
            )
            
            self.cacheService?.getPrivateCache(
                successHandler: { (data) in
                    self.data = data
            },
                failureHandler: { (error) in
            }
            )
            
            self.cacheService?.getPrivateCache(
                successHandler: { (data) in
                    self.data = data
            },
                failureHandler: { (error) in
            }
            )
            
            self.cacheService?.getPrivateCache(
                successHandler: { (data) in
                    self.data = data
            },
                failureHandler: { (error) in
            }
            )
            
        }
   
     
        
    }
    
    
    func testRawCache() {
        
        let asyncExpectation = expectation(description: "GetPublicCache")
        
     //   debugPrint("FIRST \(URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: Endpoints.GET_PUBLIC_CACHE)!)))")
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.request(Endpoints.GET_PUBLIC_CACHE).responseJSON { response in
            print("Request1: \(String(describing: response.request))")   // original url request
            print("Response1: \(String(describing: response.response))") // http url response
            print("Result1: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
            
    //        debugPrint("SECOND \(URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: Endpoints.GET_PUBLIC_CACHE)!)))")
            
            sleep(2)
            
            
            
            sessionManager.request(Endpoints.GET_PUBLIC_CACHE).responseJSON { response in
                print("Request2: \(String(describing: response.request))")   // original url request
                print("Response2: \(String(describing: response.response))") // http url response
                print("Result2: \(response.result)")                         // response serialization result
                
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)") // original server data as UTF8 string
                }
                
                asyncExpectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            debugPrint(URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: Endpoints.GET_PRIVATE_CACHE)!))?.storagePolicy.rawValue)
            XCTAssert(URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: Endpoints.GET_PUBLIC_CACHE)!)) != nil)
        }
        
        
        
    }
    
}

