//
//  MockUserAuthParser.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct MockUserAuthParser: UserAuthParserProtocol
{
    func toJson(username: String, password: String) -> Parameters
    {
        let credentials = MockClientCredentialsProvider()
        
        return [
            "username": username,
            "password": password,
            "client_id": credentials.getClientId(),
            "client_secret": credentials.getClientSecret(),
            "grant_type": "password"
        ]
    }
    
    func fromJson(jsonData: Data) -> (
        userToken: AccessToken,
        refreshToken: AccessToken,
        additionalData: [String : AnyObject]?)?
    {
        let jsonData = try! JSON(data: jsonData)
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
        
        return (userToken: userToken, refreshToken: refreshToken, additionalData: nil)
    }
}
