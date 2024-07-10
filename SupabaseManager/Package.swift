// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

//let package = Package(
//    name: "SupabaseManager",
//    platforms: [
//        .iOS(.v15),
//    ],
//    products: [
//        // Products define the executables and libraries a package produces, making them visible to other packages.
//        .library(
//            name: "SupabaseManager",
//            targets: ["SupabaseManager"]),
//    ],
//    dependencies: [
//        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0") // Add the package
//    ],
//    targets: [
//        .target(name: "SupabaseManager",
//                dependencies: ["Supabase"])
//    ]
//)


let package = Package(
    name: "SupabaseManager",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SupabaseManager",
            targets: ["SupabaseManager"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/supabase-community/supabase-swift.git",
            from: "2.0.0"
        ),
    ],
    targets: [
        .target(
            name: "SupabaseManager",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]// Add as a dependency
        )
    ]
)
