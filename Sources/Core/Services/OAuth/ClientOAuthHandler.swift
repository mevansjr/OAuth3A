//
//  ClientOAuthHandler.swift
//  
//
//  Created by Mark Evans on 1/9/17.
//  Copyright © 2017 3Advance, LLC. All rights reserved.
//

import Foundation

public class ClientOAuthHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private var clientID: String
    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - Initialization
    
    public init(clientID: String, baseURLString: String, accessToken: String, refreshToken: String) {
        self.clientID = clientID
        self.baseURLString = baseURLString
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    // MARK: - RequestAdapter
    
    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let url = urlRequest.url, url.absoluteString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // MARK: - RequestRetrier
    
    public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        }
        else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        isRefreshing = true
        AuthService.shared.refreshToken(refreshToken: refreshToken) { [weak self] (success, _) in
            guard let strongSelf = self else { return }
            if
                let token = success as? Token,
                let accessToken = token.accessToken,
                let refreshToken = token.refreshToken
            {
                completion(true, accessToken, refreshToken)
            }
            else {
                completion(false, nil, nil)
            }
            strongSelf.isRefreshing = false
        }
    }
}
