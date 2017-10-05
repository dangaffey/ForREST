//
//  MockAppAuthParser.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct MockAppAuthParser: AppAuthParserProtocol
{
    func toJson(clientId: String, clientSecret: String) -> Parameters
    {
        return [
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": "client_credentials"
        ]
    }
    
    func fromJson(jsonData: Data) -> AccessToken?
    {
        let jsonData = JSON(data: jsonData)
        guard let accessToken = jsonData["access_token"].string else {
            return nil
        }
        
        guard let expiresIn = jsonData["expires_in"].int else {
            return nil
        }
        
        let date = Date().addingTimeInterval(TimeInterval(expiresIn))
        return AccessToken(id: accessToken, expiration: date.dateToISO8601String())
    }
}
