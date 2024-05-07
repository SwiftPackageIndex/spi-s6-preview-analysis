import ArgumentParser
import Foundation
import System


enum Status: String, Codable {
    case ok
    case failed
    case infrastructureError
    case triggered
    case timeout
}


struct Record: Decodable {
    var url: String
    var status: Status
    var swift6Errors: String?
    var logUrl: String?
    var jobUrl: String
}


@main
struct S6Analysis: ParsableCommand {
    @Argument(help: "The JSON file to process.")
    var inputFile: String

    var inputFileURL: URL {
        var path = FilePath(FileManager.default.currentDirectoryPath)
        path.append(inputFile)
        return URL(filePath: path.string)
    }

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    func run() throws {
        let data = try Data(contentsOf: inputFileURL)
        let result = try decoder.decode([Record].self, from: data)
        print("results loaded (\(result.count) records)")
    }
}
