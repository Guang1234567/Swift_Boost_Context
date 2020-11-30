// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "Swift_Boost_Context",
        products: [
            // Products define the executables and libraries produced by a package, and make them visible to other packages.
            .library(
                    name: "Swift_Boost_Context",
                    type: .dynamic,
                    targets: ["Swift_Boost_Context"]),
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            // .package(url: /* package url */, from: "1.0.0"),
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages which this package depends on.
            .target(
                    name: "Swift_Boost_Context",
                    dependencies: [/*"C_Boost_Context",*/"C_Boost_Context_fcontext"]),
            .target(
                    name: "C_Boost_Context_fcontext",
                    path: "Sources/C_Boost_Context_fcontext",
                    exclude: ["./asm"],
                    //sources: ["./fcontext.S", "./helper.c"],
                    cSettings: [
                        .headerSearchPath("include"),
                        .unsafeFlags([""], .when(platforms: [.macOS])),
                        .unsafeFlags([""], .when(platforms: [.iOS])),
                        .unsafeFlags([""], .when(platforms: [.android])),
                        .unsafeFlags([""], .when(platforms: [.linux]))
                    ],
                    swiftSettings: [
                        .unsafeFlags([""], .when(platforms: [.macOS])),
                        .unsafeFlags([""], .when(platforms: [.iOS])),
                        .unsafeFlags([""], .when(platforms: [.android])),
                        .unsafeFlags([""], .when(platforms: [.linux]))
                    ]
            ),
            /*.target(
                    name: "C_Boost_Context_fcontext_prebuild",
                    dependencies: [],
                    linkerSettings: [
                        .linkedLibrary("fcontext"),
                        .unsafeFlags(["-LSources/C_Boost_Context_fcontext_prebuild/libs/osx"], .when(platforms: [.macOS]))
                    ]
            ),*/
            /*.target(
                    name: "C_Boost_Context",
                    path: "Sources/C_Boost_Context"
            ),*/
            .target(
                    name: "Example",
                    dependencies: ["Swift_Boost_Context"]
            ),
            .testTarget(
                    name: "Swift_Boost_ContextTests",
                    dependencies: ["Swift_Boost_Context"]),
        ],
        cxxLanguageStandard: .cxx11
)
