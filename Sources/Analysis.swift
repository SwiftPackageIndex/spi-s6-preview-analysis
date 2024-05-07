import Foundation

struct Analysis: Codable {
    var resultFiles: [ResultFile]
    var packageLists: [PackageList]

    struct ResultFile: Codable {
        var date: String
        var fileName: String
    }

    struct PackageList: Codable {
        var name: String
        var fileName: String
    }

    struct Package: Codable {
        var id: UUID
        var lastCommit: String
        var spiUrl: String
    }


    struct Record: Codable {
        var url: String
        var status: Status
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
    static func load(relativePath path: String) throws -> Self {
        try Self.decoder.decode(Analysis.self, from: try Data(contentsOf: .init(relativePath: path)))
    }

    func loadPackageLists() throws -> [(name: String, packages: [Package])] {
        try packageLists.map {
            let packages = try Self.decoder.decode([Package].self, from: try Data(contentsOf: .init(relativePath: $0.fileName)))
            return ($0.name, packages)
        }
    }

    func loadRecords() throws -> [(date: String, records: [Record])] {
        try resultFiles.map {
            let records = try Self.decoder.decode([Record].self, from: try Data(contentsOf: .init(relativePath: $0.fileName)))
            return ($0.date, records)
        }
    }
}


