import PackageDescription

let package = Package(
    name: "langserver-swift",
    targets: [
        Target(name: "JSONRPC"),
        Target(name: "LanguageServer", dependencies: ["JSONRPC"])
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueSocket.git", majorVersion: 0, minor: 11),
        .Package(url: "../SourceKitten", majorVersion: 0),
        .Package(url: "../XCGLogger", majorVersion: 4)
    ]
)