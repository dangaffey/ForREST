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
            break
        }
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
    
    
    
}
