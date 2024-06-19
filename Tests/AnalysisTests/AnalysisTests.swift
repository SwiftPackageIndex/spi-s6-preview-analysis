import XCTest

@testable import Analysis


class AnalysisTests: XCTestCase {

    func test_Array_filter_packages() throws {
        do {
            let results: [Analysis.Record] = [.init(url: .url0), .init(url: .url1)]
            let packages: [Analysis.Package] = [.init(url: .url1), .init(url: .url2)]
            XCTAssertEqual(results.filter(by: packages).map(\.url), [.url1])
        }
        do {
            let results: [Analysis.Record] = [.init(url: .url0), .init(url: .url1)]
            let packages: [Analysis.Package] = []
            XCTAssertEqual(results.filter(by: packages).map(\.url), [])
        }
        do {
            let results: [Analysis.Record] = []
            let packages: [Analysis.Package] = [.init(url: .url1), .init(url: .url2)]
            XCTAssertEqual(results.filter(by: packages).map(\.url), [])
        }
    }

    func test_Dictionary_maxErrors() throws {
        let results: [URL: [Analysis.Record]] = [
            .url0: [.init(url: .url0, errorCount: 1), .init(url: .url0, errorCount: 2)],
            .url1: [.init(url: .url1, errorCount: nil)],
            .url2: [.init(url: .url2, errorCount: nil), .init(url: .url2, errorCount: 3)],
        ]
        XCTAssertEqual(results.maxErrors(url: .url0), 2)
        XCTAssertEqual(results.maxErrors(url: .url1), nil)
        XCTAssertEqual(results.maxErrors(url: .url2), 3)
    }

    func test_Array_errorTotal() throws {
        let results: [Analysis.Record] = [
            .init(url: .url0, errorCount: 1), .init(url: .url0, errorCount: 2),
            .init(url: .url1, errorCount: nil),
            .init(url: .url2, errorCount: nil), .init(url: .url2, errorCount: 3),
        ]
        XCTAssertEqual(results.errorTotal(), 5)
    }

    func test_Dictionay_isPassing() throws {
        let results: [URL: [Analysis.Record]] = [
            .url0: [.init(url: .url0, platform: "a", errorCount: 1), .init(url: .url0, platform: "b", errorCount: 0)],
            .url1: [.init(url: .url1, platform: "a", errorCount: nil)],
            .url2: [.init(url: .url2, platform: "a", errorCount: nil), .init(url: .url2, platform: "b", errorCount: 3)],
        ]
        XCTAssertEqual(results.isPassing(url: .url0), true)
        XCTAssertEqual(results.isPassing(url: .url1), false)
        XCTAssertEqual(results.isPassing(url: .url2), false)
    }

    func test_Array_passingTotal() throws {
        let results: [Analysis.Record] = [
            .init(url: .url0, platform: "a", errorCount: 1), .init(url: .url0, platform: "b", errorCount: 0),
            .init(url: .url1, platform: "a", errorCount: nil),  // does not pass - must have 0 value
            .init(url: .url2, platform: "a", errorCount: nil), .init(url: .url2, platform: "b", errorCount: 3),
        ]
        XCTAssertEqual(results.passingTotal(), 1)
    }

}


extension URL {
    static let url0 = URL(string: "https://spi.com/url-1")!
    static let url1 = URL(string: "https://spi.com/url-2")!
    static let url2 = URL(string: "https://spi.com/url-3")!
}


private extension Analysis.Record {
    init(url: URL, platform: String = "", errorCount: Int? = nil) {
        self.init(url: url, status: .ok, platform: platform, swift6Errors: errorCount?.description, logUrl: nil, jobUrl: "")
    }
}


private extension Analysis.Package {
    init(url: URL) {
        self.init(lastCommit: "", url: url)
    }
}
