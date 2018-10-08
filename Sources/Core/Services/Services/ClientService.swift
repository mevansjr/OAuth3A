//
//  ClientService.swift
//
//
//  Created by Mark Evans on 12/17/15.
//  Copyright © 2015 3Advance, LLC. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

public class ClientService {

    // MARK: Properties

    public var hasBranchIdentity = false
    public var anonymousUserLoggedIn = false
    public var userLoggedIn = false
    public var currentUser: UserDetail?
    public var manager = SessionManager()
    public var currentToken = ""
    public var oauthHandler: ClientOAuthHandler?

    public typealias CompletionHandler = (_ success: Any?, _ error: NSError?) -> Void
    public typealias CompletionBoolHandler = (_ success: Bool) -> Void

    public static let DEFAULT_ERROR_CODE = 500
    public static let DEFAULT_ERROR_MSG = "There was a problem accessing the server. If this continues, please let us know."

    // MARK: Shared Instance

    public static let shared: ClientService = {
        let instance = ClientService()
        instance.setupManager()
        return instance
    }()

    // MARK: Setup Methods

    public func setupManager() {
        let configuration = URLSessionConfiguration.default
        self.manager = SessionManager(configuration: configuration)
        self.setupManangerAndOAuthHandler()
    }
}

public extension ClientService {
    func setupManangerAndOAuthHandler() {
        self.oauthHandler = self.getClientOAuthHandler()
        self.manager.adapter = self.oauthHandler
        self.manager.retrier = self.oauthHandler
    }

    func setupManangerAndOAuthHandler(json: String) {
        self.oauthHandler = self.saveTokenAndRetreiveOAuthHandler(json)
        self.manager.adapter = self.oauthHandler
        self.manager.retrier = self.oauthHandler
    }

    func saveToken(_ json: String) {
        UserDefaults.standard.set(json, forKey: Token.tokenKey)
        UserDefaults.standard.synchronize()
    }

    public func saveOAuthToken(_ token: Token) {
        oauthHandler = saveTokenAndRetreiveOAuthHandler(token: token)
        manager.adapter = oauthHandler
        manager.retrier = oauthHandler
    }

    public func saveOAuthToken(token: Token, completion: @escaping CompletionBoolHandler) {
        oauthHandler = saveTokenAndRetreiveOAuthHandler(token: token)
        manager.adapter = oauthHandler
        manager.retrier = oauthHandler
        DispatchQueue.main.async {
            completion(true)
        }
    }

    public func saveTokenAndRetreiveOAuthHandler(token: Token) -> ClientOAuthHandler? {
        if let json = Mapper<Token>().toJSONString(token, prettyPrint: true) {
            saveToken(json)
        }
        return self.getClientOAuthHandler()
    }

    public func saveTokenAndRetreiveOAuthHandler(_ json: String) -> ClientOAuthHandler? {
        saveToken(json)
        return self.getClientOAuthHandler()
    }

    public func clearTokenAndOAuthHandler() {
        UserDefaults.standard.removeObject(forKey: Token.tokenKey)
        UserDefaults.standard.synchronize()
        self.oauthHandler = nil
        self.manager.adapter = self.oauthHandler
        self.manager.retrier = self.oauthHandler
        setupManager()
    }

    func getClientOAuthHandler() -> ClientOAuthHandler? {
        var token: Token?
        if let json = UserDefaults.standard.value(forKey: Token.tokenKey) as? String {
            token = Mapper<Token>().map(JSONString: json)
        }
        if token != nil {
            guard let accessToken = token?.accessToken else {
                return nil
            }
            guard let refreshToken = token?.refreshToken else {
                return nil
            }
            return ClientOAuthHandler(clientID: API.shared.ApiClientId, baseURLString: API.shared.ApiEndpoint, accessToken: accessToken, refreshToken: refreshToken)

        }
        return nil
    }

    func errorHandler(completion: @escaping CompletionHandler) -> (DataResponse<Data>) -> Void {
        return { (res) in
            if let error = res.result.error, let response = res.response {
                print("errorHandler: \(error.localizedDescription)")
                print("errorHandler response: \(response.debugDescription)")
                completion(nil, error.handleError(response: response))
            }
            else if let error = res.result.error {
                print("errorHandler: \(error.localizedDescription)")
                completion(nil, error.handleError())
            }
        }
    }

    func errorHandler(completion: @escaping CompletionBoolHandler) -> (DataResponse<Data>) -> Void {
        return { (res) in
            if let error = res.result.error, let response = res.response {
                print("errorHandler BOOL: \(error.localizedDescription)")
                print("errorHandler BOOL response: \(response.debugDescription)")
                print("ERROR BOOL: \(error.handleError(response: response))")
                completion(false)
            }
            else if let error = res.result.error {
                print("errorHandler BOOL: \(error.localizedDescription)")
                print("ERROR BOOL: \(error.handleError())")
                completion(false)
            }
        }
    }
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return self.localizedDescription }

    func handleError() -> NSError {
        return handleError(response: nil)
    }

    func handleError(response: HTTPURLResponse?) -> NSError {
        var message = ""
        var status = self.code
        if let messageResponse = response?.allHeaderFields["Message"] as? String, !messageResponse.isEmpty, let statusCode = response?.statusCode {
            message = messageResponse
            status = statusCode
        }
        else if let messageResponse = response?.allHeaderFields["message"] as? String, !messageResponse.isEmpty, let statusCode = response?.statusCode {
            message = messageResponse
            status = statusCode
        }
        else {
            message = "There was a problem accessing the server. If this continues, please let us know."
            status = 500
        }
        if self.domain.contains("401") { status = 401 }
        return NSError(domain: message, code: status, userInfo: nil)
    }
}
