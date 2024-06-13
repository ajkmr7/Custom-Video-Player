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
    ],
    targets: [
        .target(
            name: "CustomVideoPlayer",
            dependencies: [
                "SnapKit"
            ],
            path: "Custom-Video-Player",
            resources: [.copy("Assets/*")]
        )
    ]
)
