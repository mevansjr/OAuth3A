// swift-tools-version:4.2
//
//  OAuth3A.swift
//  OAuth3A
//
//  Created by Mark Evans on 23/10/15.
//  Copyright © 2017 mevansjr. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "OAuth3A",
    products: [
        .library(
            name: "OAuth3A",
            targets: ["OAuth3A"]),
        ],
    dependencies: [],
    targets: [
        .target(
            name: "OAuth3A",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "OAuth3ATests",
            dependencies: ["OAuth3A"],
            path: "Tests")
    ]
)
