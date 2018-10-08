//
// UserDetail.swift
//
//	Create by Mark Evans
//	Copyright © 2018. All rights reserved.
//

import Foundation

public class UserDetail: NSObject, Mappable {

    public enum UserStatus: String { 
        case pending = "pending"
        case confirmed = "confirmed"
        case registered = "registered"
        case banned = "banned"
    }
    public enum EntityStatus: Int { 
        case _0 = 0
        case number1 = -1
    }
    var userId: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var username: String?
    var phoneCountryCode: String?
    var phoneNumber: String?
    var accountLockedDate: String?
    var isAccountLocked: Bool = false
    public var userStatus: String?
    var profileImageFilename: String?
    var profileImageUri: String?
    var createdDateTime: String?
    var createdUserId: Int?
    var updatedDateTime: String?
    var updatedUserId: Int?
    var deletedDateTime: String?
    var deletedUserId: Int?
    public var entityStatus: Int = 0

    class func newInstance(_ map: Map) -> Mappable? {
        return UserDetail()
    }
    public required init?(map: Map){}
    override init(){}

    public func mapping(map: Map) { 
        userId <- map["UserId"]
        firstName <- map["FirstName"]
        lastName <- map["LastName"]
        email <- map["Email"]
        username <- map["Username"]
        phoneCountryCode <- map["PhoneCountryCode"]
        phoneNumber <- map["PhoneNumber"]
        accountLockedDate <- map["AccountLockedDate"]
        isAccountLocked <- map["IsAccountLocked"]
        userStatus <- map["UserStatus"]
        profileImageFilename <- map["ProfileImageFilename"]
        profileImageUri <- map["ProfileImageUri"]
        createdDateTime <- map["CreatedDateTime"]
        createdUserId <- map["CreatedUserId"]
        updatedDateTime <- map["UpdatedDateTime"]
        updatedUserId <- map["UpdatedUserId"]
        deletedDateTime <- map["DeletedDateTime"]
        deletedUserId <- map["DeletedUserId"]
        entityStatus <- map["EntityStatus"]
    }
}

extension UserDetail {
    var isRegistered: Bool {
        if let userStatus = ClientService.shared.currentUser?.userStatus, !userStatus.isEmpty, userStatus == UserDetail.UserStatus.registered.rawValue {
            return true
        }
        return false
    }

    var isConfirmed: Bool {
        if let userStatus = ClientService.shared.currentUser?.userStatus, !userStatus.isEmpty, userStatus == UserDetail.UserStatus.confirmed.rawValue {
            return true
        }
        return false
    }

    var isPending: Bool {
        if let userStatus = ClientService.shared.currentUser?.userStatus, !userStatus.isEmpty, userStatus == UserDetail.UserStatus.pending.rawValue {
            return true
        }
        return false
    }

    var userRegisteredButNotMember: Bool {
        if isRegistered {
            return true
        }
        return false
    }

    var userLoggedInButNotRegistered: Bool {
        if isPending || isConfirmed {
            return true
        }
        return false
    }

    var isLoggedIn: Bool {
        if isRegistered {
            return true
        }
        return false
    }
}
