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

        // total error count
        // - for each date in results
        // - join all package list with results
        // - get total error count (get the max across platforms)

        var allOutput = [Analysis.Output]()
        do {
            print("all packages...")
            guard let selectedPackages = packageLists["All"] else {
                fatalError("Package list 'All' not found")
            }
            let included = Set(selectedPackages.map(\.id))
            var output = Analysis.Output(id: "all", name: "All packages", values: [])
            for (date, results) in records {
                print("date:", date, results.count)
                let selectetResults = results.filter { included.contains($0.id) }
                print("selected results:", selectetResults.count)
                let grouped = Dictionary(grouping: selectetResults) { $0.id }
                let maxErrors = grouped.keys.compactMap { grouped.maxErrors(packageId: $0) }
                let errorTotal = maxErrors.reduce(0, +)
                print("errorTotal:", errorTotal)
                output.values.append(.init(date: date, value: errorTotal))
            }
            allOutput.append(output)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(allOutput)
        try data.write(to: URL(relativePath: "out-errors.json"))
    }
}


//extension UUID {
//    static let swiftArgumentParser = UUID(uuidString: "112bdd86-7bbb-490f-9484-bd4020ed5a50")!
//}