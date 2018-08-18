//
//  DataUploadPrototype.swift
//  ForREST
//
//  Created by Dan Gaffey on 1/10/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public class DataUploadPrototype<T>: HttpDataUploadProtocol
{
    public typealias AggregatedHandler = T
    
    private var type: RequestType = RequestType.NoAuthRequired
    private var url: URLConvertible = ""
    private var method: HTTPMethod
    private var data: Data
    private var contentType: String
    private var aggregatedHandler: AggregatedHandler

    public init(
        type: RequestType,
        url: URLConvertible,
        method: HTTPMethod,
        data: Data,
        contentType: String,
        aggregatedHandler: AggregatedHandler) {
        self.type = type
        self.url = url
        self.method = method
        self.data = data
        self.contentType = contentType
        self.aggregatedHandler = aggregatedHandler
    }
    
    public func getType() -> RequestType {
        return type
    }
    
    public func getUrl() -> URLConvertible {
        return url
    }
    
    public func getMethod() -> HTTPMethod {
        return method
    }
    
    public func getData() -> Data {
        return data
    }
    
    public func getContentType() -> String {
        return contentType
    }
    
    public func getAggregatedHandler() -> AggregatedHandler {
        return aggregatedHandler
    }
}

