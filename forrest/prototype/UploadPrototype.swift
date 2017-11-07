//
//  UploadPrototype.swift
//  ForREST
//
//  Created by Dan Gaffey on 11/7/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public class UploadPrototype<T>: HttpUploadableProtocol
{
    public typealias EntityHandler = T
    
    private var type: RequestType = RequestType.NoAuthRequired
    private var url: URLConvertible = ""
    private var data: (MultipartFormData) -> ()
    private var responseHandler: EntityHandler
    
    public init(
        type: RequestType,
        url: URLConvertible,
        data: @escaping (MultipartFormData) -> (),
        responseHandler: EntityHandler) {
        self.type = type
        self.url = url
        self.data = data
        self.responseHandler = responseHandler
    }
    
    public func getType() -> RequestType {
        return type
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
