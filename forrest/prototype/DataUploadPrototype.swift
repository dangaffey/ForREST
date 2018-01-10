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
    public typealias EntityHandler = T
    
    private var type: RequestType = RequestType.NoAuthRequired
    private var url: URLConvertible = ""
    private var data: Data
    private var contentType: String
    private var responseHandler: EntityHandler
    
    public init(
        type: RequestType,
        url: URLConvertible,
        data: Data,
        contentType: String,
        responseHandler: EntityHandler) {
        self.type = type
        self.url = url
        self.data = data
        self.contentType = contentType
        self.responseHandler = responseHandler
    }
    
    public func getType() -> RequestType {
        return type
    }
    
    public func getUrl() -> URLConvertible {
        return url
    }
    
    public func getData() -> Data {
        return data
    }
    
    public func getContentType() -> String {
        return contentType
    }
    
    public func getResponseHandler() -> EntityHandler {
        return responseHandler
    }
}

