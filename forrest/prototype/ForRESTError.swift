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
    
    
    public init(_ type: ForRESTErrorType, error: Error) {
        self.type = type
        self.reason = error.localizedDescription
    }
    
    public init(_ type: ForRESTErrorType, response: DataResponse<Data>) {
        self.type = type
        self.httpCode = response.getStatusCode()
        
        if let apiData = response.data {
            self.reason = String(data: apiData, encoding: .utf8)
        }
    }
  
    public init(_ type: ForRESTErrorType) {
        self.type = type
        self.reason = type.rawValue
    }
}
