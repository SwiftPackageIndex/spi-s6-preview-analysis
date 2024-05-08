import XCTest

@testable import Analysis


class AnalysisTests: XCTestCase {
    func test_Array_filter_packages() throws {
        do {
            let results: [Analysis.Record] = [.init(id: .id0), .init(id: .id1)]
            let packages: [Analysis.Package] = [.init(id: .id1), .init(id: .id2)]
            XCTAssertEqual(results.filter(by: packages).map(\.id), [.id1])
        }
        do {
            let results: [Analysis.Record] = [.init(id: .id0), .init(id: .id1)]
            let packages: [Analysis.Package] = []
            XCTAssertEqual(results.filter(by: packages).map(\.id), [])
        }
        do {
            let results: [Analysis.Record] = []
            let packages: [Analysis.Package] = [.init(id: .id1), .init(id: .id2)]
            XCTAssertEqual(results.filter(by: packages).map(\.id), [])
        }
    }

    func test_Array_maxErrors() throws {
        let results: [UUID: [Analysis.Record]] = [
            .id0: [.init(id: .id0, errorCount: 1), .init(id: .id0, errorCount: 2)],
            .id1: [.init(id: .id1, errorCount: nil)],
            .id2: [.init(id: .id2, errorCount: nil), .init(id: .id2, errorCount: 3)],
        ]
        XCTAssertEqual(results.maxErrors(packageId: .id0), 2)
        XCTAssertEqual(results.maxErrors(packageId: .id1), nil)
        XCTAssertEqual(results.maxErrors(packageId: .id2), 3)
    }
}


extension UUID {
    static let id0 = UUID(uuidString: "00000000-0d49-4782-92f3-0e3430febed8")!
    static let id1 = UUID(uuidString: "11111111-2722-42ee-9fcd-a3fba0910622")!
    static let id2 = UUID(uuidString: "22222222-5dd4-471d-bb81-ddeabad83069")!
}


private extension Analysis.Record {
    init(id: UUID, errorCount: Int? = nil) {
        self.init(id: id, url: "", status: .ok, platform: "", swift6Errors: errorCount?.description, logUrl: nil, jobUrl: "")
    }
}


private extension Analysis.Package {
    init(id: UUID) {
        self.init(id: id, lastCommit: "", spiUrl: "")
    }
}
