import Foundation

struct Analysis: Codable {
    var runs: [RunInfo]
    var packageLists: [PackageList]

    struct RunInfo: Codable {
        var date: String
        var fileName: String
        var toolchainId: String
        var toolchainLabel: String
    }

    struct PackageList: Codable {
        var id: String
        var name: String
        var fileName: String
    }

    struct Package: Codable {
        var id: UUID
        var lastCommit: String
        var spiUrl: String
    }


    struct Record: Codable {
        var id: UUID
        var url: String
        var status: Status
        var platform: String
        var swift6Errors: String?
        var logUrl: String?
        var jobUrl: String

        enum Status: String, Codable {
            case ok
            case failed
            case infrastructureError
            case triggered
            case timeout
        }
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}


extension Analysis {
    struct Output: Codable {
        var id: String
        var name: String
        var values: [Value]

        struct Value: Codable {
            var date: String
            var toolchainId: String
            var toolchainLabel: String
            var value: Int
        }
    }
}


extension Analysis {
    static func load(relativePath path: String) throws -> Self {
        try Self.decoder.decode(Analysis.self, from: try Data(contentsOf: .init(relativePath: path)))
    }

    func loadPackageLists() throws -> [(id: String, name: String, packages: [Package])] {
        try packageLists.map {
            let packages = try Self.decoder.decode([Package].self, from: try Data(contentsOf: .init(relativePath: $0.fileName)))
            return ($0.id, $0.name, packages)
        }
    }

    func loadRecords() throws -> [(run: RunInfo, records: [Record])] {
        try runs.map {
            let records = try Self.decoder.decode([Record].self, from: try Data(contentsOf: .init(relativePath: $0.fileName)))
            return ($0, records)
        }
    }
}


extension [Analysis.Record] {
    func filter(by packages: [Analysis.Package]) -> Self {
        let isIncluded = Set(packages.map(\.id))
        return filter { isIncluded.contains($0.id) }
    }

    func errorTotal() -> Int {
        let grouped = Dictionary(grouping: self) { $0.id }
        let maxErrors = grouped.keys.compactMap { grouped.maxErrors(packageId: $0) }
        return maxErrors.reduce(0, +)
    }

    func passingTotal() -> Int {
        let grouped = Dictionary(grouping: self) { $0.id }
        let passing = grouped.keys.filter { grouped.isPassing(packageId: $0) }
        return passing.count
    }
}


extension Array<(id: String, name: String, packages: [Analysis.Package])> {
    subscript(id id: String) -> Element? {
        for element in self {
            if element.id == id { return element }
        }
        return nil
    }
}


extension Dictionary<UUID, [Analysis.Record]> {
    func maxErrors(packageId: UUID) -> Int? {
        guard let records = self[packageId] else { return nil }
        let errors = records.compactMap(\.swift6Errors).compactMap(Int.init)
        guard !errors.isEmpty else { return nil }
        return errors.max()
    }

    func isPassing(packageId: UUID) -> Bool {
        guard let records = self[packageId] else { return false }
        let buildsWithoutErrors = records.compactMap(\.swift6Errors).compactMap(Int.init).filter { $0 == 0 }
        return buildsWithoutErrors.isEmpty == false
    }
}
