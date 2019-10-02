//
//  NullResponseHandler.swift
//  ForREST
//
//  Created by Daniel Gaffey on 8/13/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


open class NullHandler: ResponseHandleableProtocol, ErrorHandleableProtocol, NullCallbackProtocol
{
    public var successCallback: () -> ()
    public var failureCallback: (ForRESTError) -> ()
    
    private lazy var metricsTracker: RequestMetricsProtocol? = {
        return NetworkConfig.sharedInstance.getMetricsTracker()
    }()
    
    public init(
        successCallback: @escaping () -> (),
        failureCallback: @escaping (ForRESTError) -> ())
    {
        self.successCallback = successCallback
        self.failureCallback = failureCallback
    }
    
    open func handleResponse(response: DataResponse<Data>)
    {
        switch response.result {
            
        case .success(_):
            successCallback()
            break
            
        case .failure(let error):
            failureCallback(ForRESTError(.apiError, error: error))
            trackAPIError(response)
            break
        }
        trackAPILatency(response)
    }
    
    /**
     Proxy helper function that allows the transmission of an error directly to a callback
     Useful for when errors need relayed that are not a result of handling a network response
     */
    public func handleError(_ error: ForRESTError) {
        getFailureCallback()(error)
    }
    
    
    public func getSuccessCallback() -> () -> ()
    {
        return successCallback
    }
    
    public func getFailureCallback() -> (ForRESTError) -> ()
    {
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
            tracker.trackAPIError(requestMethod: method, path: path, error: errorString, errorCode: response.getStatusCode())
        }
    }
    
}
