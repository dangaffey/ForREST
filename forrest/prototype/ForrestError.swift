//
//  ForrestError.swift
//  ForREST
//
//  Created by Dan Gaffey on 7/5/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation

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
    
    var type: ForrestErrorType
    var error: Error?
    var response: String?
    
    init(_ type: ForrestErrorType, error: Error?, response: String?) {
        self.type = type
        self.error = error
        self.response = response
    }
    
    init(_ type: ForrestErrorType, error: Error?, responseData: Data?) {
        self.type = type
        self.error = error
        
        if let data = responseData {
            self.response = String(data: data, encoding: .utf8)
        }
    }
}

