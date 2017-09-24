//
//  MockUserAuthParser.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


struct MockUserAuthParser: UserAuthParserProtocol
{
    func toJson(username: String, password: String) -> Parameters
    {
        return [:]
    }
    
    func fromJson(jsonData: Data) -> (
        userToken: AccessToken,
        refreshToken: AccessToken,
        additionalData: [String : AnyObject]?)?
    {
        return nil
    }
}
