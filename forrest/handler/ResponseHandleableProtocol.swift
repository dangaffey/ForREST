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
    
    func handleResponse(response: DataResponse<Data>) -> ()
    
    func getSuccessCallback() -> (EntityType) -> ()
    
    func getFailureCallback() -> (Error) -> ()
}
