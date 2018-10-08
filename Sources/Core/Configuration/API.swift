//
//
//  Secure.swift
//
//  Created by Mark Evans on 2/22/17.
//  Copyright © 2017 3Advance, LLC. All rights reserved.
//

import Foundation

@objc public class API: NSObject {
    
    public let ApiEndpoint = "https://api-nudge-dev.azurewebsites.net"
    public let ApiClientId = "ios"
    public let ApiClientSecret = "W3]IZN&mcm.&.gWGIPIs+>pmf"
    
    public static let shared: API = {
        let instance = API()
        return instance
    }()
    
}
