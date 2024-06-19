import Foundation

enum Analysis {
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

    static func loadResults(_ path: String) throws -> [Record] {
        let url = URL(filePath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([Record].self, from: data)
    }
}

func main() throws {
    let f1 = CommandLine.arguments[1]
    let f2 = CommandLine.arguments[2]

    print("diffing", f1, f2, "...")
    let res1 = try Analysis.loadResults(f1)
    let res2 = try Analysis.loadResults(f2)

    let urls1 = Set(res1.map(\.url))
    let urls2 = Set(res2.map(\.url))

    print("Missing in results 2:")
    for url in urls1.subtracting(urls2) {
        print("   ", url)
    }
    print("Missing in results 1:")
    for url in urls2.subtracting(urls1) {
        print("   ", url)
    }

    let common = urls1.intersection(urls2)
}

try main()
