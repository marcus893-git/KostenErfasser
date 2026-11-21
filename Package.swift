// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "KostenErfasser",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "KostenErfasserCore", targets: ["KostenErfasserCore"])
    ],
    targets: [
        .target(name: "KostenErfasserCore"),
        .testTarget(name: "KostenErfasserCoreTests", dependencies: ["KostenErfasserCore"]),
    ]
)
