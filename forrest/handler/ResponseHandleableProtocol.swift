//
//  DataResponseProtocol.swift
//  ForREST
//
//  Created by Daniel Gaffey on 9/24/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public protocol ResponseHandleableProtocol
{
    associatedtype EntityType
    
    public func handleResponse(response: DataResponse<Data>) -> ()
    
    public func getSuccessCallback() -> (EntityType) -> ()
    
    public func getFailureCallback() -> (Error) -> ()
}
