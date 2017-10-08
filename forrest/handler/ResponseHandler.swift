//
//  ResponseHandler.swift
//  ForREST
//
//  Created by Daniel Gaffey on 9/24/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public class ResponseHandler<T>: ResponseHandleableProtocol
{
    typealias EntityType = T
    
    var parserClosure: (Data) -> (EntityType?)
    var successCallback: (EntityType) -> ()
    var failureCallback: (Error) -> ()
    
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
    
    func handleResponse(response: DataResponse<Data>)
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
    
    
    func getSuccessCallback() -> (EntityType) -> ()
    {
        return successCallback
    }
    
    func getFailureCallback() -> (Error) -> ()
    {
        return failureCallback
    }
    
    
    
}
