import Foundation

//
//  HttpRequestProtocol.swift
//  forrest
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire


public enum RequestType {
    case UserAuthRequired
    case AppAuthRequired
    case NoAuthRequired
}

protocol HttpRequestableProtocol {
    
    associatedtype ResponseEntity
    
    func getType() -> RequestType
    
    func getMethod() -> HTTPMethod
    
    func getUrl() -> URLConvertible
    
    func getParams() -> Parameters?
    
    func getEncoding() -> ParameterEncoding
    
    func getResponseHandler() -> ResponseEntity
}
