//
//  ForRESTErrorHandableProtocol.swift
//  ForREST
//
//  Created by Daniel Gaffey on 8/16/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation

public protocol ErrorHandleableProtocol {
    
    func handleError(_ error: ForRESTError) -> ()
    
}
