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
        return "1_422z1wuwbq4gk8ww0cgwss0440g8k40cwo0k84sgso0k8ogc8c"
        //return "3_3pzyv6ad5c00gokcskwkwg0ssw4skks0g00swwssk8w00soo8w"
    }
    
    func getClientSecret() -> String
    {
        return "15fw65u986lccsk84kg0go0g4kokgk4ck8kw0ogs00ws0088c8"
        //return "5u13lky3x7s4sc0sg8kkowsk0okg4gkk000ko4ow80k48k4o84"
    }
}
