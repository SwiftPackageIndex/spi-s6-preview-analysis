import Foundation

enum Analysis {
    struct Record: Codable {
        var url: URL
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

    static func loadList(_ path: String) throws -> [URL] {
        struct Item: Codable {
            var url: URL
        }
        let url = URL(filePath: path)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Item].self, from: data).map(\.url)
    }
}

func main() throws {
    let list = CommandLine.arguments[1]
    let f1 = CommandLine.arguments[2]
    let f2 = CommandLine.arguments[3]

    let packageUrls = try Analysis.loadList(list)
    print("Packages in list:", packageUrls.count)

    print("diffing", f1, f2, "...")
    let res1 = try Analysis.loadResults(f1)
    let res2 = try Analysis.loadResults(f2)

    let urls1 = Set(res1.map(\.url))
    assert(Set(packageUrls).subtracting(urls1).isEmpty, "\(f1) does not include all selected packages")
    let urls2 = Set(res2.map(\.url))
    assert(Set(packageUrls).subtracting(urls2).isEmpty, "\(f2) does not include all selected packages")

    let d1 = Dictionary(grouping: res1.filter { $0.status == .ok }, by: { $0.url })
    let d2 = Dictionary(grouping: res2.filter { $0.status == .ok }, by: { $0.url })

    for url in packageUrls {
        print(url)
        if d1[url] == nil { print("\(url) missing in \(f1)") }
        if d2[url] == nil { print("\(url) missing in \(f2)") }
        guard d1[url] != nil && d2[url] != nil else { continue }
        
        let e1 = (d1[url]!.compactMap(\.swift6Errors).compactMap(Int.init)).max()
        let e2 = (d2[url]!.compactMap(\.swift6Errors).compactMap(Int.init)).max()

        switch (e1, e2) {
            case (.none, .none):
                print("    ", "nil")
            case let (.none, .some(v2)):
                print("    ", "nil", v2)
            case let (.some(v1), .none):
                print("    ", v1, "nil")
            case let (.some(v1), .some(v2)) where v1 == v2:
                print("    ", "==", v1)
            case let (.some(v1), .some(v2)) where v1 < v2:
                print("    ", "❌", v1, v2)
            case let (.some(v1), .some(v2)) where v1 > v2:
                print("    ", "✅", v1, v2)
            default:
                fatalError("unhandled case")
        }
    }
}

try main()
