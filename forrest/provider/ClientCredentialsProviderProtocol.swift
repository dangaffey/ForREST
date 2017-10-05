//
//  ClientCredentialsProviderProtocol.swift
//  ForREST
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation


public protocol ClientCredentialsProviderProtocol
{
    func getClientId() -> String
    
    func getClientSecret() -> String
}
