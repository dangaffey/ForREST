//
//  MockClientCredentialsProvider.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation

struct MockClientCredentialsProvider: ClientCredentialsProviderProtocol
{
    func getClientId() -> String
    {
        return ""
    }
    
    func getClientSecret() -> String
    {
        return ""
    }
}
