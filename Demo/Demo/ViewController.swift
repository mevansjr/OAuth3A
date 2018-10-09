//
//  ViewController.swift
//  Demo
//
//  Created by Mark Evans on 10/8/18.
//  Copyright © 2018 Mark Evans. All rights reserved.
//

import UIKit
import OAuth3A

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        AuthService.shared.loginAnonymous { (success, error) in
            if let err = error {
                print("Error: \(err.domain)")
                return
            }
            else if let token = success as? Token, let json = token.toJSONString(prettyPrint: true) {
                print("Anonymous Token: \(json)")
            }
        }
    }


}

