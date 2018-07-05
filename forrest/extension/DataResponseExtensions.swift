//
//  DataResponseExtensions.swift
//  ForREST
//
//  Created by Dan Gaffey on 7/5/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

extension DataResponse {
    
    func getStatusCode() -> Int {
        guard let code = response?.statusCode else {
            return -1
        }
        return code
    }
    
    
}
