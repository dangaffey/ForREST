//
//  OptionalResponseHandleableProtocol.swift
//  ForREST
//
//  Created by Daniel Gaffey on 8/13/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public protocol OptionalEntityCallbackProtocol
{
    associatedtype EntityType
    
    func getSuccessCallback() -> (EntityType?) -> ()
    
}
