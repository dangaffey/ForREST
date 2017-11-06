//
//  MockRefreshParser.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct MockRefreshParser: RefreshParserProtocol
{
    func toJson(token: String) -> Parameters
    {
        return [
            "grant_type" : "refresh_token",
            "refresh_token" : token,
            "client_id" : MockClientCredentialsProvider().getClientId(),
            "client_secret" : MockClientCredentialsProvider().getClientSecret()
        ]
    }
    
    func fromJson(jsonData: Data) -> (userToken: AccessToken, refreshToken: AccessToken)?
    {
        let jsonData = JSON(data: jsonData)
        guard let accessToken = jsonData["access_token"].string else {
            return nil
        }
        
        guard let expiresIn = jsonData["expires_in"].int else {
            return nil
        }
        
        let date = Date().addingTimeInterval(TimeInterval(expiresIn))
        let userToken = AccessToken(id: accessToken, expiration: date.dateToISO8601String())
        
        
        guard let token = jsonData["refresh_token"].string else {
            return nil
        }
        
        let refreshToken = AccessToken(id: token, expiration: "")
        
        return (userToken: userToken, refreshToken: refreshToken)
    }
}
