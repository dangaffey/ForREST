//
//  RequestPrototype.swift
//  forrest
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire

class RequestPrototype: HttpRequestProtocol
{    
    var type: RequestType = RequestType.NoAuthRequired
    var method: HTTPMethod = .get
    var url: URLConvertible = ""
    var params: Parameters?
    var parameterEncoding: ParameterEncoding = JSONEncoding.default
    var responseCallback: ((DataResponse<Data>) -> Void)
    
    init(
        type: RequestType,
        method: HTTPMethod,
        url: URLConvertible,
        params: Parameters?,
        parameterEncoding: ParameterEncoding,
        responseCallback: @escaping ((DataResponse<Data>) -> Void))
    {
        self.type = type
        self.method = method
        self.url = url
        self.params = params
        self.parameterEncoding = parameterEncoding
        self.responseCallback = responseCallback
    }
    
    func getType() -> RequestType {
        return type
    }
    
    func getMethod() -> HTTPMethod {
        return method
    }
    
    func getUrl() -> URLConvertible {
        return url
    }
    
    func getParams() -> Parameters? {
        return params
    }
    
    func getEncoding() -> ParameterEncoding {
        return parameterEncoding
    }
    
    func getResponseCallback() -> ((DataResponse<Data>) -> Void) {
        return responseCallback
    }
}
