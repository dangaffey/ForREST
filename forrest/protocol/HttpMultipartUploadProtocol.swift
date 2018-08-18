//
//  HttpUploadableProtocol.swift
//  ForREST
//
//  Created by Dan Gaffey on 11/7/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


protocol HttpMultipartUploadProtocol {
    
    associatedtype AggregatedHandler
    
    func getType() -> RequestType
    
    func getMethod() -> HTTPMethod
    
    func getUrl() -> URLConvertible
    
    func getData() -> (MultipartFormData) -> ()
    
    func getAggregatedHandler() -> AggregatedHandler
}
