//
//  ResponseHandler.swift
//  ForREST
//
//  Created by Daniel Gaffey on 9/24/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

open class ResponseHandler<T>: ResponseHandleableProtocol
{
    public typealias EntityType = T
    
    public var parserClosure: (Data) -> (EntityType?)
    public var successCallback: (EntityType) -> ()
    public var failureCallback: (ForrestError) -> ()
    
    private lazy var metricsTracker: RequestMetricsProtocol? = {
        return NetworkConfig.sharedInstance.getMetricsTracker()
    }()
    
    public init(
        parserClosure: @escaping (Data) -> (EntityType?),
        successCallback: @escaping (EntityType) -> (),
        failureCallback: @escaping (ForrestError) -> ()) {
        self.parserClosure = parserClosure
        self.successCallback = successCallback
        self.failureCallback = failureCallback
    }
    
    
    open func handleResponse(response: DataResponse<Data>) {
        switch response.result {
            case .success(let data):
                guard let contentObject = parserClosure(data) else {
                    getFailureCallback()(ForrestError(.parseError, error: nil, responseData: data))
                    return
                }
                getSuccessCallback()(contentObject)
                break
                
            case .failure(let error):
                getFailureCallback()(ForrestError(.apiError, error: error, responseData: response.data))
                trackAPIError(response)
                break
        }
        trackAPILatency(response)
    }
    
    
    open func getSuccessCallback() -> (EntityType) -> () {
        return successCallback
    }
    
    open func getFailureCallback() -> (ForrestError) -> () {
        return failureCallback
    }
    
    public func trackAPILatency(_ response: DataResponse<Data>) {
        if let tracker = metricsTracker,
            let method = response.request?.httpMethod,
            let path = response.request?.url?.path {
            tracker.trackAPILatency(
                requestMethod: method,
                path: path,
                timeElapsed: String(format: ".3f", response.timeline.requestDuration)
            )
        }
    }
    
    public func trackAPIError(_ response: DataResponse<Data>) {
        if let tracker = metricsTracker,
            let method = response.request?.httpMethod,
            let path = response.request?.url?.path,
            let data = response.data,
            let errorString = String(data: data, encoding: .utf8) {
            tracker.trackAPIError(requestMethod: method, path: path, error: errorString)
        }
    }
    

}
