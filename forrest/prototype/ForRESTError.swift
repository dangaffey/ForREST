//
//  ForrestError.swift
//  ForREST
//
//  Created by Dan Gaffey on 7/5/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

open class ForRESTError {
    public var type: ForRESTErrorType
    public var httpCode: Int = -1
    public var reason: String?
    public var error: Error?
    
    public init(_ type: ForRESTErrorType, response: DataResponse<Data>? = nil, error: Error? = nil) {
        self.type = type
        
        self.httpCode = response?.getStatusCode() ?? -1
        if let apiData = response?.data {
            self.reason = String(data: apiData, encoding: .utf8)
        }
        
        self.error = error
    }
}
