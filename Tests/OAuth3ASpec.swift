//
//  OAuth3ASpec.swift
//  OAuth3A
//
//  Created by Mark Evans on 04/10/16.
//  Copyright © 2017 mevansjr. All rights reserved.
//

import Quick
import Nimble
@testable import OAuth3A

class OAuth3ASpec: QuickSpec {

    override func spec() {

        describe("OAuth3ASpec") {
            it("works") {
                expect(OAuth3A.name) == "OAuth3A"
            }
        }

    }

}
