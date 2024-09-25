// swift-tools-version: 5.8

import PackageDescription
import class Foundation.ProcessInfo

let package = Package(
    name: "chat-asn1",
    platforms: [ .macOS(.v12), .iOS(.v13) ],
    products: [ .library(name: "chat-asn1", targets: ["ASN1SCG"]), ],
    targets: [ .target(name: "ASN1SCG", dependencies: [ 
       .product(name: "SwiftASN1", package: "swift-asn1"), ]), ]
)

if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
    package.dependencies += [
       .package(url: "https://github.com/apple/swift-asn1.git", from: "0.8.0"), ]
}
