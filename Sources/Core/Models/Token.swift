//
//  Token.swift
//
//
//  Created by Mark Evans on 6/27/17.
//  Copyright © 2017 3Advance, LLC. All rights reserved.
//

import Foundation

public class Token: NSObject, Mappable {

    public static let tokenKey = "TokenKey"

    var accessToken : String?
    var tokenType : String?
    var expiresIn : Double?
    var refreshToken : String?

    class func newInstance(_ map: Map) -> Mappable? {
        return Token()
    }
    public required init?(map: Map){}
    override init(){}

    public func mapping(map: Map) {
        accessToken <- map["access_token"]
        tokenType <- map["token_type"]
        expiresIn <- map["expires_in"]
        refreshToken <- map["refresh_token"]
    }
    
}
