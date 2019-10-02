//
//  LatencyTrackingProtocol.swift
//  ForREST
//
//  Created by Dan Gaffey on 7/3/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation

public protocol RequestMetricsProtocol
{
    func trackAPILatency(requestMethod: String, path: String, timeElapsed: String) -> ()
    
    func trackAPIError(requestMethod: String, path: String, error: String, errorCode: Int) -> ()
}
