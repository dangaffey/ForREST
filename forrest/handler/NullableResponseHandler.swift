//
//  NullableResponseHandler.swift
//  ForREST
//
//  Created by Daniel Gaffey on 11/6/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

/**
    Class used for cases like HTTP204 where a successful response may return nothing
*/
open class NullableResponseHandler<T>: ResponseHandleableProtocol
{
    public typealias EntityType = T
    
    public var parserClosure: (Data) -> (EntityType?)
    public var successCallback: (EntityType?) -> ()
    public var failureCallback: (Error) -> ()
    
    public init(
        parserClosure: @escaping (Data) -> (EntityType?),
        successCallback: @escaping (EntityType?) -> (),
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
            
            //TODO parser should throw if there is an error,
            //with an HTTP204 we cannot know that a nil response
            //was from No Content or from a parser issue so the onus is
            //now on the parser to indicate that
            
            guard let contentObject = parserClosure(data) else {
                successCallback(nil)
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
