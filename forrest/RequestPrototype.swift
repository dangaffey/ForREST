//
//  RequestPrototype.swift
//  ForREST
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire

public class RequestPrototype<T>: HttpRequestableProtocol
{
    typealias EntityHandler = T
    
    var type: RequestType = RequestType.NoAuthRequired
    var method: HTTPMethod = .get
    var url: URLConvertible = ""
    var params: Parameters?
    var parameterEncoding: ParameterEncoding = JSONEncoding.default
    var responseHandler: EntityHandler
    
    init(
        type: RequestType,
        method: HTTPMethod,
        url: URLConvertible,
        params: Parameters?,
        parameterEncoding: ParameterEncoding,
        responseHandler: EntityHandler)
    {
        self.type = type
        self.method = method
        self.url = url
        self.params = params
        self.parameterEncoding = parameterEncoding
        self.responseHandler = responseHandler
    }
    
    func getType() -> RequestType
    {
        return type
    }
    
    func getMethod() -> HTTPMethod
    {
        return method
    }
    
    func getUrl() -> URLConvertible
    {
        return url
    }
    
    func getParams() -> Parameters?
    {
        return params
    }
    
    func getEncoding() -> ParameterEncoding
    {
        return parameterEncoding
    }
    
    func getResponseHandler() -> EntityHandler
    {
        return responseHandler
    }
}
