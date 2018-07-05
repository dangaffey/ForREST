//
//  ForrestError.swift
//  ForREST
//
//  Created by Dan Gaffey on 7/5/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public enum ForrestErrorType: String {
    case appAuthFailed = "App Auth Failed"
    case userAuthFailed = "User Auth Failed"
    case refreshFailed = "User Refresh Failed"
    
    case expiredAppToken = "App Token Expired"
    case expiredUserToken = "User Token Expired"
    
    case persistError = "Storage Error"
    case referenceError = "Memory Reference Error"
    case parseError = "Parse Error"
    case apiError = "Api Error"
}


public class ForrestError {
    public var type: ForrestErrorType
    public var httpCode: Int = -1
    public var reason: String?
    
    
    public init(_ type: ForrestErrorType, error: Error) {
        self.type = type
        self.reason = error.localizedDescription
    }
    
    public init(_ type: ForrestErrorType, response: DataResponse<Data>) {
        self.type = type
        self.httpCode = response.getStatusCode()
        
        if let apiData = response.data {
            self.reason = String(data: apiData, encoding: .utf8)
        }
    }
  
    public init(_ type: ForrestErrorType) {
        self.type = type
        self.reason = type.rawValue
    }
}
