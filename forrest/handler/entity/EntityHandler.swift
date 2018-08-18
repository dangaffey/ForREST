//
//  ResponseHandler.swift
//  ForREST
//
//  Created by Daniel Gaffey on 9/24/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

open class EntityHandler<T>: ResponseHandleableProtocol
{
    public typealias EntityType = T
    
    public var parserClosure: (Data) -> (EntityType?)
    public var successCallback: (EntityType) -> ()
    public var failureCallback: (ForRESTError) -> ()
    
    private lazy var metricsTracker: RequestMetricsProtocol? = {
        return NetworkConfig.sharedInstance.getMetricsTracker()
    }()
    
    public init(
        parserClosure: @escaping (Data) -> (EntityType?),
        successCallback: @escaping (EntityType) -> (),
        failureCallback: @escaping (ForRESTError) -> ()) {
        self.parserClosure = parserClosure
        self.successCallback = successCallback
        self.failureCallback = failureCallback
    }
    
    open func handleResponse(response: DataResponse<Data>)
    {
        switch response.result {
            case .success(let data):
                guard let contentObject = parserClosure(data) else {
                    failureCallback(ForRESTError(.parseError))
                    return
                }
                getSuccessCallback()(contentObject)
                break
                
            case .failure(_):
                getFailureCallback()(ForRESTError(.apiError, response: response))
                trackAPIError(response)
                break
        }
        trackAPILatency(response)
    }
    
    
    open func getSuccessCallback() -> (EntityType) -> () {
        return successCallback
    }
    
    open func getFailureCallback() -> (ForRESTError) -> () {
        return failureCallback
    }
    
    public func trackAPILatency(_ response: DataResponse<Data>) {
        if let tracker = metricsTracker,
            let method = response.request?.httpMethod,
            let path = response.request?.url?.path {
            tracker.trackAPILatency(
                requestMethod: method,
                path: path,
                timeElapsed: String(format: "%.2f", response.timeline.requestDuration)
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
