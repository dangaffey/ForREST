//
//  AccessToken.swift
//  ForREST
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation

struct AccessToken
{
    var id: String
    var expiration: String
    
    init(id: String, expiration: String)
    {
        self.id = id
        self.expiration = expiration
    }
    
    func getId() -> String
    {
        return id
    }
    
    func getExpiration() -> String
    {
        return expiration
    }
}
