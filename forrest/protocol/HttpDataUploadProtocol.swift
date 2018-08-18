//
//  HttpRawUploadableProtocol.swift
//  ForREST
//
//  Created by Dan Gaffey on 1/10/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


protocol HttpDataUploadProtocol {
    
    associatedtype AggregatedHandler
    
    func getType() -> RequestType
    
    func getMethod() -> HTTPMethod
    
    func getUrl() -> URLConvertible
    
    func getData() -> Data
    
    func getContentType() -> String
    
    func getAggregatedHandler() -> AggregatedHandler
}
