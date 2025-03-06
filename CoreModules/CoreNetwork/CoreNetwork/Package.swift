// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreNetwork",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CoreNetwork",
            targets: ["CoreNetwork"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
         .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
         .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CoreNetwork",
            dependencies: ["Alamofire",
                           .product(name: "RxMoya", package: "Moya"),
                           .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
                          ])
    ]
)
