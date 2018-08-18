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
    public typealias AggregatedHandler = T
    
    var type: RequestType = RequestType.NoAuthRequired
    var method: HTTPMethod = .get
    var url: URLConvertible = ""
    var contentType: String?
    var params: Parameters?
    var parameterEncoding: ParameterEncoding = JSONEncoding.default
    var aggregatedHandler: AggregatedHandler
    
    public init(
        type: RequestType,
        method: HTTPMethod,
        url: URLConvertible,
        params: Parameters?,
        parameterEncoding: ParameterEncoding,
        aggregatedHandler: AggregatedHandler)
    {
        self.type = type
        self.method = method
        self.url = url
        self.params = params
        self.parameterEncoding = parameterEncoding
        self.aggregatedHandler = aggregatedHandler
    }
    
    public init(
        type: RequestType,
        method: HTTPMethod,
        url: URLConvertible,
        contentType: String?,
        params: Parameters?,
        parameterEncoding: ParameterEncoding,
        aggregatedHandler: AggregatedHandler)
    {
        self.type = type
        self.method = method
        self.url = url
        self.contentType = contentType
        self.params = params
        self.parameterEncoding = parameterEncoding
        self.aggregatedHandler = aggregatedHandler
    }
    
    
    public func getType() -> RequestType
    {
        return type
    }
    
    public func getMethod() -> HTTPMethod
    {
        return method
    }
    
    public func getUrl() -> URLConvertible
    {
        return url
    }
    
    public func getContentType() -> String? {
        return contentType
    }
    
    public func getParams() -> Parameters?
    {
        return params
    }
    
    public func getEncoding() -> ParameterEncoding
    {
        return parameterEncoding
    }
    
    public func getAggregatedHandler() -> AggregatedHandler
    {
        return aggregatedHandler
    }
}
