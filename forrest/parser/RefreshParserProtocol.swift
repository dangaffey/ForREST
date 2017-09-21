//
//  RefreshParserProtocol.swift
//  forrest
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire

protocol RefreshParserProtocol
{
    func toJson(token: String) -> Parameters
    
    func fromJson(jsonData: Data) -> (userToken: AccessToken, refreshToken: AccessToken)?
}

