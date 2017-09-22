//
//  MockRefreshParser.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


struct MockRefreshParser: RefreshParserProtocol
{
    func toJson(token: String) -> Parameters
    {
        return [:]
    }
    
    func fromJson(jsonData: Data) -> (userToken: AccessToken, refreshToken: AccessToken)?
    {
        return nil
    }
}
