import ArgumentParser
import Foundation


@main
struct S6Analysis: ParsableCommand {
    @Argument(help: "The JSON file to process.")
    var inputFile: String

    func run() throws {
        let analysis = try Analysis.load(relativePath: inputFile)
        let packageLists = try analysis.loadPackageLists()
        print(packageLists.map(\.name), packageLists.map(\.packages.count))
        let records = try analysis.loadRecords()
        print(records.map(\.date), records.map(\.records.count))
    }
}


