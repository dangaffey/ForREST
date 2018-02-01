//
//  CacheService.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 1/31/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


class CacheService
{
    static let sharedInstance = CacheService(
        httpClient: OAuthHttpClient.sharedInstance
    )
    
    let httpClient: OAuthHttpClient
    
    private init(httpClient: OAuthHttpClient)
    {
        self.httpClient = httpClient
    }
    
    
    public func getPublicCache(
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
            url: Endpoints.GET_PUBLIC_CACHE,
            params: nil,
            parameterEncoding: URLEncoding.default,
            responseHandler: responseHandler
        )
        
        httpClient.addRequestToQueue(request: request)
    }
    
    
    public func getPrivateCache(
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
            url: Endpoints.GET_PRIVATE_CACHE,
            params: nil,
            parameterEncoding: URLEncoding.default,
            responseHandler: responseHandler
        )
        
        
        debugPrint("PRIVATE CACHE ENTRY: \(URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: Endpoints.GET_PRIVATE_CACHE)!)))")
        httpClient.addRequestToQueue(request: request)
    }
}
