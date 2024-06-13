// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CustomVideoPlayer",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "CustomVideoPlayer",
            targets: ["CustomVideoPlayer"]
        ),
    ],
    dependencies: [
        .package(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "CustomVideoPlayer",
            dependencies: [
                "SnapKit",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseDatabase", package: "firebase-ios-sdk"),
            ],
            path: "Custom-Video-Player",
            resources: [.copy("Assets/*")]
        )
    ]
)
