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
            var errorCountOutput = [Analysis.Output]()
            for listId in ["all", "apple", "sswg"] {
                print("all packages...")
                guard let packageList = packageLists[id: listId] else {
                    fatalError("Package list 'All' not found")
                }
                var output = Analysis.Output(id: packageList.id, name: packageList.name, values: [])
                for (date, results) in records {
                    print("date:", date, results.count)
                    let selectetResults = results.filter(by: packageList.packages)
                    print("selected results:", selectetResults.count)
                    let errorTotal = selectetResults.errorTotal()
                    print("errorTotal:", errorTotal)
                    output.values.append(.init(date: date, value: errorTotal))
                }
                errorCountOutput.append(output)
            }

            let data = try encoder.encode(errorCountOutput)
            try data.write(to: URL(relativePath: "rfs6-errors.json"))
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
