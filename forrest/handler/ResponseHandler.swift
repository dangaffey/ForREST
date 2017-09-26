//
//  ResponseHandler.swift
//  forrest
//
//  Created by Daniel Gaffey on 9/24/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

class ResponseHandler<T>: DataResponseProtocol
{
    var parserClosure: (Data) -> (T?)
    var successCallback: (T) -> ()
    var failureCallback: (Error) -> ()
    
    init(
        parserClosure: @escaping (Data) -> (T?),
        successCallback: @escaping (T) -> (),
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
    
    
    func getSuccessCallback() -> (T) -> ()
    {
        return successCallback
    }
    
    func getFailureCallback() -> (Error) -> ()
    {
        return failureCallback
    }
    
    
    
}
