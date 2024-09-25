// swift-tools-version: 5.8

import PackageDescription
import class Foundation.ProcessInfo

let package = Package(
    name: "chat-x509",
    platforms: [ .macOS(.v12), .iOS(.v13) ],
    products: [ .executable(name: "chat-x509", targets: ["Suite"]), ],
    targets: [ .executableTarget(name: "Suite", dependencies: [ .product(name: "SwiftASN1", package: "swift-asn1"), ]), ]
)

if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
    package.dependencies += [ .package(url: "https://github.com/apple/swift-asn1.git", from: "1.2.0"), ]
}
