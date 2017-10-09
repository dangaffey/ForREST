//
//  AccessToken.swift
//  ForREST
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation

public struct AccessToken
{
    var id: String
    var expiration: String
    
    public init(id: String, expiration: String)
    {
        self.id = id
        self.expiration = expiration
    }
    
    public func getId() -> String
    {
        return id
    }
    
    public func getExpiration() -> String
    {
        return expiration
    }
}
