// swift-tools-version: 5.8

import PackageDescription
import class Foundation.ProcessInfo

let package = Package(
    name: "chat-asn1",
    platforms: [ .macOS(.v12), .iOS(.v13) ],
    products: [ .executable(name: "chat-asn1", targets: ["ASN1SCG"]), ],
    targets: [
      .executableTarget(
         name: "ASN1SCG",
         dependencies: [
            .product(name: "Crypto", package: "swift-crypto"),
            .product(name: "_CryptoExtras", package: "swift-crypto"),
            .product(name: "SwiftASN1", package: "swift-asn1"),
         ]),
    ]
)

if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.6.0"),
        .package(url: "https://github.com/apple/swift-asn1.git", from: "0.8.0"),
    ]
}
