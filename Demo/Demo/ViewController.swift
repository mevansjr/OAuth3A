//
//  ViewController.swift
//  Demo
//
//  Created by Mark Evans on 10/8/18.
//  Copyright © 2018 Mark Evans. All rights reserved.
//

import UIKit
import OAuth3A
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result

            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }

            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }

//        API.shared.ApiClientId = "ios"
//        API.shared.ApiClientSecret = "W3]IZN&mcm.&.gWGIPIs+>pmf"
//        API.shared.ApiEndpoint = "https://api-nudge-dev.azurewebsites.net"

        AuthService.shared.loginAnonymous { (success, _) in
            if let token = success as? Token, let json = token.toJSONString(prettyPrint: true) {
                print("Anonymous Token: \(json)")
            }
        }
    }


}

