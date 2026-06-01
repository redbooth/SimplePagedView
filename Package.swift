// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SimplePagedView",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "SimplePagedView", targets: ["SimplePagedView"])
    ],
    targets: [
        .target(
            name: "SimplePagedView",
            path: "SimplePagedViewFramework/Source"
        )
    ]
)
