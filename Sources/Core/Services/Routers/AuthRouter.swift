//
//  AuthRouter.swift
//
//  Created by 3Advance iOS Swagger Generator.
//  Copyright © 3Advance, LLC. All rights reserved.
//

enum AuthRouter: URLRequestConvertible {
    case loginAnonymous()
    case login(String, String)
    case loginSMS(String, String)
    case refreshToken(String)
    case requestCode(String)

    static let baseURLString = API.shared.ApiEndpoint

    var method: HTTPMethod {
        switch self {
            case .loginAnonymous:
                return .post
            case .login:
                return .post
            case .loginSMS:
                return .post
            case .refreshToken:
                return .post
            case .requestCode:
                return .post
        }
    }

    var path: String {
        switch self {
            case .loginAnonymous:
                return "/connect/token"
            case .login:
                return "/oauth/token"
            case .loginSMS:
                return "/connect/token"
            case .refreshToken:
                return "/connect/token"
            case .requestCode:
                return "/me/code"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try AuthRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
            case .loginAnonymous:
                let parameters = ["grant_type": "anonymous",
                    "client_id": API.shared.ApiClientId,
                    "client_secret": API.shared.ApiClientSecret,
                    "resource": API.shared.ApiEndpoint]
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)

            case .login(let username, let password):
                let parameters = [
                    "username": username,
                    "password": password,
                    "grant_type": "password",
                    "client_id": API.shared.ApiClientId,
                    "client_secret": API.shared.ApiClientSecret
                ]
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            
            case .loginSMS(let code, let phoneNumber):
                let parameters = [
                    "code": code,
                    "phonenumber": phoneNumber,
                    "grant_type": "timebasedcode",
                    "client_id": API.shared.ApiClientId,
                    "client_secret": API.shared.ApiClientSecret,
                    "resource": API.shared.ApiEndpoint,
                    "scope": "offline_access"
                ]
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            
            case .refreshToken(let refreshToken):
                let parameters = [
                    "refresh_token": refreshToken,
                    "grant_type": "refresh_token",
                    "client_id": API.shared.ApiClientId,
                    "client_secret": API.shared.ApiClientSecret]
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)

            case .requestCode(let phoneNumber):
                var parameters = [String: Any]()
                parameters["PhoneNumber"] = phoneNumber
                parameters["PhoneCountryCode"] = "+1"
                urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }
        return urlRequest
    }
}
