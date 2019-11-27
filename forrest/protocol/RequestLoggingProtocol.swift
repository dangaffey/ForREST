//
//  RequestLoggingProtocol.swift
//  ForREST
//
//  Created by JT Smrdel on 11/27/19.
//  Copyright © 2019 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public protocol RequestLoggingProtocol {
    
    func requestExecuted(requestURL: URLConvertible)
}
