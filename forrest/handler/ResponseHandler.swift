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
    public var failureCallback: (Error) -> ()
    
    public init(
        parserClosure: @escaping (Data) -> (EntityType?),
        successCallback: @escaping (EntityType) -> (),
        failureCallback: @escaping (Error) -> ())
    {
        self.parserClosure = parserClosure
        self.successCallback = successCallback
        self.failureCallback = failureCallback
    }
    
    //track time using response.timeline object
    
    open func handleResponse(response: DataResponse<Data>)
    {
        switch response.result {
                
            case .success(let data):
                guard let contentObject = parserClosure(data) else {
                    failureCallback(ForrestError.parseError)
                    return
                }
    
                successCallback(contentObject)
                break
                
            case .failure(let error):
                failureCallback(error)
                break
        }
    }
    
    
    public func getSuccessCallback() -> (EntityType) -> ()
    {
        return successCallback
    }
    
    public func getFailureCallback() -> (Error) -> ()
    {
        return failureCallback
    }
    
    

}
