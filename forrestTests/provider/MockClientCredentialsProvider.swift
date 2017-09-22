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
    }
    
    func getClientSecret() -> String
    {
        return "15fw65u986lccsk84kg0go0g4kokgk4ck8kw0ogs00ws0088c8"
    }
}
