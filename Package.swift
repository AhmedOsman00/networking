// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "networking",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
  ],
  products: [
    .library(
      name: "Networking",
      targets: ["Networking"]
    ),
    .library(
      name: "Pager",
      targets: ["Pager"]
    ),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Networking",
      dependencies: []
    ),
    .target(
      name: "Pager",
      dependencies: ["Networking"]
    ),
    .testTarget(
      name: "NetworkingTests",
      dependencies: ["Networking", "Pager"]
    ),
  ]
)
