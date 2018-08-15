//
//  NullResponseHandler.swift
//  ForREST
//
//  Created by Daniel Gaffey on 8/13/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


open class NullResponseHandler: NullResponseHandleableProtocol
{
    public var successCallback: () -> ()
    public var failureCallback: (Error) -> ()
    
    public init(
        successCallback: @escaping () -> (),
        failureCallback: @escaping (Error) -> ())
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
            failureCallback(error)
            break
        }
    }
    
    
    public func getSuccessCallback() -> () -> ()
    {
        return successCallback
    }
    
    public func getFailureCallback() -> (Error) -> ()
    {
        return failureCallback
    }
    
    
    
}
