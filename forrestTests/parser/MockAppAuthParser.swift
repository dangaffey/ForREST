//
//  MockAppAuthParser.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


struct MockAppAuthParser: AppAuthParserProtocol
{
    func toJson(clientId: String, clientSecret: String) -> Parameters
    {
        return [:]
    }
    
    func fromJson(jsonData: Data) -> AccessToken?
    {
        
        return nil
    }
}
