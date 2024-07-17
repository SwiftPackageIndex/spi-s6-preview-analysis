import ArgumentParser
import Foundation
// FIXME: temporary hack until the API has settled
@testable import Analysis


@main
struct S6Analysis: ParsableCommand {
    @Argument(help: "The JSON file to process.")
    var inputFile: String

    func run() throws {
        let analysis = try Analysis.load(relativePath: inputFile)
        let packageLists = try analysis.loadPackageLists()
        let records = try analysis.loadRecords()

        do {  // Analyse total error count
            print("Analysing total error count ...\n")

            var errorCountOutput = [Analysis.Output]()
            for listId in ["all", "apple", "sswg"] {
                print("Analysing '\(listId)' packages...")
                guard let packageList = packageLists[id: listId] else {
                    fatalError("Package list '\(listId)' not found")
                }
                // The Apple list contains duplicates - both /apple/... and /swiftlang/... urls - to deal with the ongoing
                // transition of repositories from the apple to the swiftlang Github org.
                let packageCount = listId == "apple" ? packageList.packages.count / 2 : packageList.packages.count
                var output = Analysis.Output(id: packageList.id, name: packageList.name, total: packageCount, values: [])
                for (run, results) in records {
                    print("date:", run.date, results.count)
                    let selectedResults = results.filter(by: packageList.packages)
                    print("selected results:", selectedResults.count)
                    let errorTotal = selectedResults.errorTotal()
                    print("errorTotal:", errorTotal)
                    output.values.append(.init(date: run.date,
                                               toolchainId: run.toolchainId,
                                               toolchainLabel: run.toolchainLabel,
                                               value: errorTotal))
                }
                errorCountOutput.append(output)
                print()
            }

            let data = try encoder.encode(errorCountOutput)
            try data.write(to: URL(relativePath: "rfs6-errors.json"))
        }

        do {  // Analyse packages without errors
            print("Analysing packages without errors ...\n")

            var passingOutput = [Analysis.Output]()
            for listId in ["all", "apple", "sswg"] {
                print("Analysing '\(listId)' packages...")
                guard let packageList = packageLists[id: listId] else {
                    fatalError("Package list '\(listId)' not found")
                }
                // The Apple list contains duplicates - both /apple/... and /swiftlang/... urls - to deal with the ongoing
                // transition of repositories from the apple to the swiftlang Github org.
                let packageCount = listId == "apple" ? packageList.packages.count / 2 : packageList.packages.count
                var output = Analysis.Output(id: packageList.id, name: packageList.name, total: packageCount, values: [])
                for (run, results) in records {
                    print("date:", run.date, results.count)
                    let selectedResults = results.filter(by: packageList.packages)
                    print("selected results:", selectedResults.count)
                    let passingTotal = selectedResults.passingTotal()
                    print("passingTotal:", passingTotal)
                    output.values.append(.init(date: run.date,
                                               toolchainId: run.toolchainId,
                                               toolchainLabel: run.toolchainLabel,
                                               value: passingTotal))
                }
                passingOutput.append(output)
                print()
            }

            let data = try encoder.encode(passingOutput)
            try data.write(to: URL(relativePath: "rfs6-packages.json"))
        }
    }
}


extension S6Analysis {
    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
