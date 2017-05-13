import PackageDescription

let package = Package(
    name: "VaporTest",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/vapor/mysql-provider", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/krzyzanowskim/CryptoSwift", majorVersion: 0, minor: 6)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

