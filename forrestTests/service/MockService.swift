//
//  MockService.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


struct MockService
{
    static let sharedInstance = MockService(
        httpClient: OAuthHttpClient.sharedInstance
    )
    
    let httpClient: OAuthHttpClient
    
    private init(httpClient: OAuthHttpClient)
    {
        self.httpClient = httpClient
    }
    
    
    
    /**
         Attempts to retrieve data from a REST endpoint without OAuth security
     */
    public func getNoAuthData(
        successHandler: @escaping (Any) -> (),
        failureHandler: @escaping (Any) -> ()
    ) {
        let responseHandler = EntityHandler<Any>(
            parserClosure: { (data: Data) -> (Any?) in
                debugPrint(data)
                return Int()
            },
            successCallback: { (object: Any) in
                successHandler(object)
            },
            failureCallback: { (error: ForRESTError) in
                failureHandler(error)
            }
        )
        
        let request = RequestPrototype<EntityHandler<Any>>(
            type: RequestType.noAuthRequired,
            method: .get,
            url: Endpoints.GET_NO_AUTH_DATA,
            params: nil,
            parameterEncoding: URLEncoding.default,
            aggregatedHandler: responseHandler
        )
        
        httpClient.addRequestToQueue(request: request)
    }
    
    
    
    public func getUserSecuredData(
        successHandler: @escaping (Any) -> (),
        failureHandler: @escaping (Any) -> ()) {
        
        let responseHandler = UserAuthenticatedEntityHandler<Any>(
            parserClosure: { (data: Data) -> (Any?) in
                debugPrint(data)
                return data
            },
            successCallback: { (object: Any) in
                successHandler(object)
            },
            failureCallback: { (error: ForRESTError) in
                failureHandler(error)
            }
        )
        
        let request = RequestPrototype<UserAuthenticatedEntityHandler<Any>>(
            type: RequestType.userAuthRequired,
            method: .get,
            url: Endpoints.GET_USER_DATA,
            params: nil,
            parameterEncoding: URLEncoding.default,
            aggregatedHandler: responseHandler
        )
        
        httpClient.addRequestToQueue(request: request)
    
    }

}
