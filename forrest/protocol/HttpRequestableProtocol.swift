import Foundation

//
//  HttpRequestProtocol.swift
//  ForREST
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire


protocol HttpRequestableProtocol {
    
    associatedtype EntityHandler
    
    func getType() -> RequestType
    
    func getMethod() -> HTTPMethod
    
    func getUrl() -> URLConvertible
    
    func getParams() -> Parameters?
    
    func getEncoding() -> ParameterEncoding
    
    func getContentType() -> String?
    
    func getResponseHandler() -> EntityHandler
}
