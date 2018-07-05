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
    case expiredAppToken = "App Token Expired"
    case expiredUserToken = "User Token Expired"
    case refreshFailed = "User Refresh Failed"
    case parseError = "Parse Error"
    case persistError = "Storage Error"
    case apiError = "Api Error"
}


public struct ForrestError {
    public var type: ForrestErrorType
    public var error: Error?
    public var response: DataResponse<Data>?
    
    public init(_ type: ForrestErrorType, error: Error?, response: DataResponse<Data>?) {
        self.type = type
        self.error = error
        self.response = response
    }
}
