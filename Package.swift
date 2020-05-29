// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Shuffle",
  platforms: [
    .iOS(.v9)
  ],
  products: [
    .library(
      name: "Shuffle",
      targets: ["Shuffle"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Quick", from: "2.1.0"),
    .package(url: "https://github.com/Quick/Nimble", from: "8.0.2")
  ],
  targets: [
    .target(
      name: "Shuffle",
      dependencies: []),
    .testTarget(
      name: "ShuffleTests",
      dependencies: [
        "Shuffle",
        "Quick",
        "Nimble"
      ]
    )
  ]
)
