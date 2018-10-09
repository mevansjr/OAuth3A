//
//  AuthService.swift
//
//  Created by 3Advance iOS Swagger Generator.
//  Copyright © 3Advance, LLC. All rights reserved.
//

import Foundation

public extension AuthService {

    // MARK: OAUth Methods

    func loginAnonymous(completion: @escaping CompletionHandler) {
        DispatchQueue(label: "background", qos: .background).async {
            self.manager.request(AuthRouter.loginAnonymous())
                .validate(statusCode: 200..<300)
                .responseObject { (response: DataResponse<Token>) in
                    DispatchQueue.main.async {
                        if let token = response.result.value {
                            completion(token, nil)
                        } else if let error = response.result.error {
                            completion(nil, error.handleError(response: response.response))
                        } else {
                            completion(nil, NSError(domain: AuthService.DEFAULT_ERROR_MSG, code: AuthService.DEFAULT_ERROR_CODE))
                        }
                    }
            }
        }
    }

    func requestCode(phoneNumber: String, completion: @escaping CompletionHandler) {
        DispatchQueue(label: "background", qos: .background).async {
            self.manager.request(AuthRouter.requestCode(phoneNumber))
                .validate(statusCode: 200..<300)
                .responseString { response in
                    switch(response.result) {
                    case .success(let code):
                        DispatchQueue.main.async {
                            completion(code, nil)
                        }
                        break
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(nil, error.handleError(response: response.response))
                        }
                        break
                    }
            }
        }
    }

    func loginSMS(code: String, phoneNumber: String, completion: @escaping CompletionHandler) {
        DispatchQueue(label: "background", qos: .background).async {
            self.manager.request(AuthRouter.loginSMS(code, phoneNumber))
                .validate(statusCode: 200..<300)
                .responseObject { (response: DataResponse<Token>) in
                    if let token = response.result.value {
                        completion(token, nil)
                    } else if let error = response.result.error {
                        completion(nil, error.handleError(response: response.response))
                    } else {
                        completion(nil, NSError(domain: AuthService.DEFAULT_ERROR_MSG, code: AuthService.DEFAULT_ERROR_CODE));
                    }
            }
        }
    }

    func refreshToken(refreshToken: String, completion: @escaping CompletionHandler) {
        DispatchQueue(label: "background", qos: .background).async {
            self.manager.request(AuthRouter.refreshToken(refreshToken))
                .validate(statusCode: 200..<300)
                .responseString(completionHandler: { (response) in
                    DispatchQueue.main.async {
                        switch response.result {
                        case .success(let json):
                            if let token = Mapper<Token>().map(JSONString: json) {
                                completion(token, nil)
                            }
                            else {
                                completion(nil, NSError(domain: AuthService.DEFAULT_ERROR_MSG, code: AuthService.DEFAULT_ERROR_CODE))
                            }
                        case .failure(let error):
                            completion(nil, error.handleError(response: response.response))
                        }
                    }
                })
        }
    }

    func logoutUser(completion: @escaping CompletionBoolHandler)  {
        DispatchQueue.main.async {
            AuthService.shared.anonymousUserLoggedIn = false
            AuthService.shared.userLoggedIn = false
            AuthService.shared.currentUser = nil
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            AuthService.shared.clearTokenAndOAuthHandler()
            completion(true)
        }
    }

    func logout() {
        self.logoutUser { (_) in
            self.loginAnonymous(completion: { (success, _) in
                if let token = success as? Token { AuthService.shared.saveOAuthToken(token) }
                DispatchQueue.main.async {
                    AuthService.shared.anonymousUserLoggedIn = true
                }
            })
        }
    }
    
}
