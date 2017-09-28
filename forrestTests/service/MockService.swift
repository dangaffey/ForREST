//
//  MockService.swift
//  forrestTests
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
        let responseHandler = ResponseHandler<Any>(
            parserClosure: { (data: Data) -> (Any?) in
                debugPrint(data)
                return Int()
            },
            successCallback: { (object: Any) in
                successHandler(object)
            },
            failureCallback: { (error: Error) in
                failureHandler(error)
            }
        )
        
        let request = RequestPrototype<ResponseHandler<Any>>(
            type: RequestType.NoAuthRequired,
            method: .get,
            url: Endpoints.GET_NO_AUTH_DATA,
            params: nil,
            parameterEncoding: URLEncoding.default,
            responseHandler: responseHandler
        )
        
        httpClient.addRequestToQueue(request: request)
    }
}
