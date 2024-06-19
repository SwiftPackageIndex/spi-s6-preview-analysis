import Foundation

struct Package: Codable {
    var id: UUID
    var lastCommit: String
    var spiUrl: String
}

struct PackageWithoutId: Codable {
    var lastCommit: String
    var url: String

    init(package: Package) {
        self.lastCommit = package.lastCommit
        self.url = package.spiUrl
    }
}

func loadPackages(at path: String) throws -> [Package] {
    let url = URL(filePath: path)
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode([Package].self, from: data)
}

func savePackages(_ packages: [PackageWithoutId], to path: String) throws {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.outputFormatting = .init([.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    let data = try encoder.encode(packages)
    let url = URL(filePath: path)
    try data.write(to: url)
}

func main() throws {
    let path = CommandLine.arguments[1]
    let packages = try loadPackages(at: path)
    let packagesWithoutId = packages.map(PackageWithoutId.init(package:)).sorted(by: { $0.spiUrl < $1.spiUrl })
    try savePackages(packagesWithoutId, to: path)
}

try main()
