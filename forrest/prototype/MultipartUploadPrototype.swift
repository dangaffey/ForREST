//
//  UploadPrototype.swift
//  ForREST
//
//  Created by Dan Gaffey on 11/7/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public class MultipartUploadPrototype<T>: HttpMultipartUploadProtocol
{
    public typealias EntityHandler = T
    
    private var type: RequestType = RequestType.NoAuthRequired
    private var url: URLConvertible = ""
    private var method: HTTPMethod
    private var data: (MultipartFormData) -> ()
    private var responseHandler: EntityHandler
    
    public init(
        type: RequestType,
        url: URLConvertible,
        method: HTTPMethod,
        data: @escaping (MultipartFormData) -> (),
        responseHandler: EntityHandler) {
        self.type = type
        self.url = url
        self.method = method
        self.data = data
        self.responseHandler = responseHandler
    }
    
    public func getType() -> RequestType {
        return type
    }
    
    public func getMethod() -> HTTPMethod {
        return method
    }
    
    public func getUrl() -> URLConvertible {
        return url
    }
    
    public func getData() -> (MultipartFormData) -> () {
        return data
    }
    
    public func getResponseHandler() -> EntityHandler {
        return responseHandler
    }
}
