//
//  ForRESTErrorType.swift
//  ForREST
//
//  Created by Daniel Gaffey on 8/19/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation

public enum ForRESTErrorType: String {
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
