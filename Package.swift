// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "KostenErfasser",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "KostenErfasserCore", targets: ["KostenErfasserCore"])
    ],
    targets: [
        .target(name: "KostenErfasserCore"),
        .testTarget(name: "KostenErfasserCoreTests", dependencies: ["KostenErfasserCore"]),
    ]
)
