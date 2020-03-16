//
//  UserAuthParserProtocol.swift
//  ForREST
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire

public protocol UserAuthParserProtocol
{
    func toJson(username: String, password: String, meta: [String : Any]?) -> Parameters
    
    func fromJson(jsonData: Data) -> (
        userToken: AccessToken,
        refreshToken: AccessToken,
        additionalData: [String : AnyObject]?)?
}

